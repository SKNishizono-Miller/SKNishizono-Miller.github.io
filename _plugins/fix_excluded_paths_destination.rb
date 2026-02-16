require "fileutils"
require "pathname"

Jekyll::Hooks.register :site, :post_write do |site|
  default_lang = site.config["default_lang"]
  current_lang = site.config["lang"]
  default_in_subfolder = site.config["default_locale_in_subfolder"]

  next unless default_lang == current_lang && default_in_subfolder

  exclude_paths = Array(site.config["exclude_from_localizations"])
  lang_dest = Pathname.new(site.dest)
  root_dest = lang_dest.parent
  output_dir_name = root_dest.basename.to_s

  next unless lang_dest.directory?

  Dir.children(lang_dest).each do |entry|
    source_path = lang_dest.join(entry)

    if entry == "base.html"
      target_path = root_dest.join("index.html")
      FileUtils.rm_rf(target_path)
      FileUtils.mv(source_path, target_path)
      Jekyll.logger.info("i18n-fix:", "Moved #{source_path} -> #{target_path}")
      next
    end

    next unless exclude_paths.include?(entry)
    next if entry == output_dir_name

    target_path = root_dest.join(entry)
    FileUtils.rm_rf(target_path)
    FileUtils.mv(source_path, target_path)
    Jekyll.logger.info("i18n-fix:", "Moved #{source_path} -> #{target_path}")
  end
end
