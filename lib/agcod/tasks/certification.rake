require "fileutils"

namespace :agcod do
  namespace :certification do
    desc "generate a request manifest for certification"
    task :generate_manifest do
      puts "generating manifest"
      i = 1
      prices = [
        12,
        999,
        100,
        50.02,
        999.99,
        600,
        70,
        100000,
        12,
        12,
        1
      ]

      path = File.join(FileUtils.pwd, "features", "support", "certification_requests")
      FileUtils.rm_rf(path)
      FileUtils.mkdir_p(path)

      requests = []
      prices.each do |p|
        random_string_of_numbers = ""
        12.times {random_string_of_numbers << rand(9).to_s}

        request = {"value" => p, 
          "request_id" => i.to_s + random_string_of_numbers}

        File.open(File.join(path, "#{i}.yml"), 'w') do |manifest|
          manifest.puts request.to_yaml
        end
        i += 1
      end
      
      
      puts "Manifest available at #{path}"
    end
  end
end
