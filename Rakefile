#task :default => [:js, :css]

task :default => [:js, :css]
task :js => FileList["coffee/*.coffee"].map { |f| 
  "coffee/#{File.basename(f, ".coffee")}.js" 
}
task :css => FileList["scss/*.scss"].map { |f| 
  "scss/#{File.basename(f, ".scss")}.css" 
}

rule ".js" => ".coffee" do |t|
  sh "coffee -c #{t.source}"
end

rule ".css" => ".scss" do |t|
  sh "sass #{t.source} > #{t.name}"
end

