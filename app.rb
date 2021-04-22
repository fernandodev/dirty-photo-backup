#!/usr/bin/env ruby

require 'sinatra'
require 'JSON'
require 'time'

class Application < Sinatra::Base
  DESTINATION = ENV['PHOTO_BACKUP_DESTINATION_FOLDER'] || './public'

  get('/') do
    content_type :json

    {
      status: 'ok',
      code: 200,
      destination: DESTINATION
    }.to_json
  end

  # Upload a single file
  # params
  #   heic_to_jpg - converts HEIC to JPG                               - optional
  #   mov_to_mp4  - converts MOV to MP4                                - optional
  #   keep_copy   - if converted keep both original and converted file - optional
  #   created_at  - timestamp of when the file to uploaded was created - required
  #   username    - name of the user which will be used as root folder - required
  #   file        - multipart data                                     - required
  # return json
  #   filename, code
  # exceptions
  #   1000, 1001, 1010 - bad request (missing required params)
  post '/upload' do
    content_type :json

    errors = sanitize_upload_params(params)
    if !errors.empty?
      status 400
      return {
        errors: errors,
        code: 400
      }.to_json
    end

    @heic_to_jpg = params[:heic_to_jpg] == "1"
    @mov_to_mp4 = params[:mov_to_mp4] == "1"
    @keep_copy = params[:keep_copy] == "1"
    @filename = params[:file][:filename]
    @file = params[:file][:tempfile]
    @is_heic = File.extname(@file).downcase == ".heic"
    @is_mov = File.extname(@file).downcase == ".mov"
    @output_dir = [
      DESTINATION,
      build_directory(params[:username], params[:created_at])
    ].join '/'
    @output_file = "#{@output_dir}/#{@filename}"

    FileUtils.mkdir_p @output_dir
    File.open(@output_file, 'wb') do |f|
      f.write(@file.read)
    end

    convert_heic_jpg(@output_file) if @is_heic && @heic_to_jpg
    convert_mov_mp4(@output_file) if @is_mov && @mov_to_mp4

    `rm "#{@output_file}"` unless @keep_copy

    status 201

    {
      filename: @filename,
      code: 201
    }.to_json
  end

  def sanitize_upload_params(params)
    errors = []

    errors << { message: "File is required", param: "file", code: 1000 } if params[:file].nil?
    errors << { message: "Username or user unique id is required", param: "username", code: 1001 } if params[:username].nil?
    errors << { message: "Date of creation is required. Format YYYYMMDD", param: "created_at", code: 1010 } if params[:created_at].nil?

    errors
  end

  def build_directory(username, created_at)
    dir = [username]
    date = Date.parse created_at
    dir << date.year
    dir << date.month
    dir << date.day

    dir.join('/')
  end

  def convert_heic_jpg(output_file)
    `magick convert "#{output_file}" "#{output_file}.jpg"`
  end

  def convert_mov_mp4(output_file)
    `ffmpeg -i "#{output_file}" -vcodec h264 -acodec mp2 "#{output_file}".mp4`
  end
end
