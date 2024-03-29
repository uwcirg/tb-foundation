namespace :image_analysis do
  desc "Add dates onto report types"
  task :read_barcodes_from_json => :environment do
    file = File.read("#{Rails.root}/tmp/barcode-reads.json")
    parsed_barcodes = JSON.parse(file)
      .select { |each| each["barcode"] < 100000 }
      .map { |each| { id: each["id"], auto_detected_barcode: each["barcode"] } }
    grouped_barcodes = parsed_barcodes.index_by { |item| item[:id] }

    ActiveRecord::Base.transaction do
      PhotoReport.update(grouped_barcodes.keys, grouped_barcodes.values)
    end
  end
end
