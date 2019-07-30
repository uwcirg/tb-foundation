require "fileutils"
require "base64"

StripReport.find_each do |sr| 

    baseURL = ENV["URL_API"]

    #Build proper file naming
    userID = sr.participant.uuid
    date = Time.parse("#{sr.created_at}").strftime("%Y%m%dT%H%M%S")
    filename = "strip_report"
    filename = "#{filename}_#{sr.id}_#{date}"
    photoDir = "/ruby/backend/upload/strip_photos/#{userID}"
    picture = Base64.decode64(sr.photo.gsub(/^data:image\/\w+;base64,/, ""));


    fullURL = "#{baseURL}/photo/#{userID}/#{filename}"
    #Attach URL to DB Table
    sr.update(url_photo: fullURL)

    #Save File to volume
    FileUtils.mkdir_p photoDir
    File.open("#{photoDir}/#{filename}.png", "wb") do |file|
        file.write(picture)
    end
    puts(filename)
end


#userID= params["userID"]
#picture = Base64.decode64(params["photo"]);

# temp = Participant.find_by(uuid: userID).strip_reports.new(
#   photo: params["photo"],
#   timestamp: params["timestamp"],
# )

# temp.url_photo = "StripReport_#{StripReport.all.count}"

# temp.save


# photoDir = "/ruby/backend/upload/strip_photos/#{userID}"

# #Make sure directory for photos exists
# FileUtils.mkdir_p photoDir

# File.open("#{photoDir}/#{temp.url_photo}.png", "wb") do |file|
# file.write(picture)
# end