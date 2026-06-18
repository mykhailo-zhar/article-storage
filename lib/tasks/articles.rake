namespace :articles do
  desc "Import articles from CSV (columns: id, title, description, url, category_labels). Example: bin/rails \"articles:import_csv[.personal/blog_posts_all.csv]\""
  task :import_csv, [ :file ] => :environment do |_task, args|
    file = args[:file].presence || ENV["FILE"]
    abort "Usage: bin/rails \"articles:import_csv[path/to/file.csv]\"" if file.blank?

    result = Articles::ImportCsv.call(file: file)

    puts "Import complete: #{result.imported_count} created, #{result.updated_count} updated."
  end
end
