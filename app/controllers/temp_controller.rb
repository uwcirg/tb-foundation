require 'zip'
class TempController < ApplicationController

    #skip_before_action :verify_authenticity_token
    before_action :decode_temp_token
    
    #Decodes jwt token sent as url parameter
    def decode_temp_token
      header = params[:token]
      header = header.split(' ').last if header
      begin
        @decoded = JsonWebToken.decode(header)
        rescue JWT::DecodeError => e
          render json: { errors: e.message }, status: :unauthorized
        end
    end

    def generate_zip
            filename = "strip_photos.zip"
            temp_file = Tempfile.new(filename)

            #Validate that this token is a temp token, and not a user token
            if( @decoded[:temp] == "true")
                test = ZipFileGenerator.new("/ruby/backend/upload/strip_photos/",temp_file.path)
                test.write()
                zip_data = File.read(temp_file.path)
                send_data(zip_data, type: 'application/zip', disposition: 'attachment', filename: filename)
            else
                render json: { errors: "Token not of type temporary" }, status: :unauthorized
            end

            ensure # important steps below
                temp_file.close
                temp_file.unlink
    end


end

# Sample taken from stak overflow
class ZipFileGenerator
    # Initialize with the directory to zip and the location of the output archive.
    def initialize(input_dir, output_file)
      @input_dir = input_dir
      @output_file = output_file
    end
  
    # Zip the input directory.
    def write
      entries = Dir.entries(@input_dir) - %w[. ..]
  
      ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
        write_entries entries, '', zipfile
      end
    end
  
    private
  
    # A helper method to make the recursion work.
    def write_entries(entries, path, zipfile)
      entries.each do |e|
        zipfile_path = path == '' ? e : File.join(path, e)
        disk_file_path = File.join(@input_dir, zipfile_path)
  
        if File.directory? disk_file_path
          recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
        else
          put_into_archive(disk_file_path, zipfile, zipfile_path)
        end
      end
    end
  
    def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      zipfile.mkdir zipfile_path
      subdir = Dir.entries(disk_file_path) - %w[. ..]
      write_entries subdir, zipfile_path, zipfile
    end
  
    def put_into_archive(disk_file_path, zipfile, zipfile_path)
      zipfile.add(zipfile_path, disk_file_path)
    end
  end


