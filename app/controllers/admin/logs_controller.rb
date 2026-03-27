# typed: false
# frozen_string_literal: true

class Admin::LogsController < AdminController
  MAX_LINES = 200
  MAX_BYTES = 128.kilobytes
  MAX_VISIBLE_FILES = 6

  before_action :disable_store

  def index
    @logs = log_sources.map { |source| build_log_entry(source) }
    @log_groups = @logs.group_by { |log| log[:group] }
  end

  private

  def disable_store
    response.set_header("Cache-Control", "no-store")
  end

  def log_sources
    sources = [
      {
        key: :rails,
        name: "Rails",
        group: "Aplicacao",
        environment: "Todos",
        description: "Erros e eventos da aplicacao Rails no ambiente #{Rails.env}",
        path: Rails.root.join("log", "#{Rails.env}.log"),
        pattern: Rails.root.join("log", "#{Rails.env}.log*").to_s
      },
      {
        key: :puma,
        name: "Puma",
        group: "Servidor local",
        environment: "Desenvolvimento",
        description: "Saida padrao do Puma quando redirecionada para arquivo",
        path: Rails.root.join("log", "puma.log"),
        pattern: Rails.root.join("log", "puma.log*").to_s
      },
      {
        key: :puma_error,
        name: "Puma stderr",
        group: "Servidor local",
        environment: "Desenvolvimento",
        description: "Erros do Puma quando redirecionados para arquivo",
        path: Rails.root.join("log", "puma-error.log"),
        pattern: Rails.root.join("log", "puma-error.log*").to_s
      },
      {
        key: :nginx_error,
        name: "Nginx error.log",
        group: "Servidor web",
        environment: "Producao",
        description: "Erros do proxy web em producao",
        path: Pathname.new("/var/log/nginx/error.log"),
        pattern: "/var/log/nginx/error.log*"
      },
      {
        key: :passenger,
        name: "Passenger",
        group: "Servidor web",
        environment: "Producao",
        description: "Log dedicado do Passenger quando configurado",
        path: Rails.root.join("log", "passenger.log"),
        pattern: Rails.root.join("log", "passenger.log*").to_s
      }
    ]

    return sources if Rails.env.production?

    sources.reject { |source| source[:environment] == "Producao" }
  end

  def build_log_entry(source)
    primary_path = source.fetch(:path)
    candidates = resolve_log_files(source.fetch(:pattern), primary_path)
    selected_path = candidates.find { |path| readable_text_log?(path) }

    source.merge(
      path: selected_path&.to_s || primary_path.to_s,
      available: selected_path.present?,
      updated_at: log_updated_at(selected_path || primary_path),
      size: log_size(selected_path || primary_path),
      lines: selected_path ? tail_lines(selected_path) : [ "Arquivo indisponivel." ],
      files: build_file_metadata(candidates)
    )
  end

  def resolve_log_files(pattern, primary_path)
    paths = Dir.glob(pattern).map { |path| Pathname.new(path) }
    paths << primary_path

    paths
      .uniq
      .select { |path| File.file?(path) }
      .sort_by { |path| sort_weight_for(path) }
  rescue SystemCallError
    [ primary_path ].select { |path| File.file?(path) }
  end

  def sort_weight_for(path)
    basename = path.basename.to_s

    if basename.end_with?(".log")
      [ 0, 0 ]
    elsif basename =~ /\.log\.(\d+)\z/
      [ 1, Regexp.last_match(1).to_i ]
    elsif basename =~ /\.log\.(\d+)\.gz\z/
      [ 2, Regexp.last_match(1).to_i ]
    else
      [ 3, basename ]
    end
  end

  def readable_log?(path)
    File.file?(path) && File.readable?(path)
  end

  def readable_text_log?(path)
    readable_log?(path) && !compressed_log?(path)
  end

  def compressed_log?(path)
    path.to_s.end_with?(".gz")
  end

  def log_updated_at(path)
    return unless path && File.exist?(path)

    File.mtime(path)
  rescue SystemCallError
    nil
  end

  def log_size(path)
    return unless path && File.exist?(path)

    File.size(path)
  rescue SystemCallError
    nil
  end

  def build_file_metadata(paths)
    paths.first(MAX_VISIBLE_FILES).map do |path|
      {
        path: path.to_s,
        compressed: compressed_log?(path),
        updated_at: log_updated_at(path),
        size: log_size(path)
      }
    end
  end

  def tail_lines(path, max_lines: MAX_LINES, max_bytes: MAX_BYTES)
    return unless File.exist?(path)
    return [ "Arquivo compactado. Visualizacao inline desabilitada." ] if compressed_log?(path)
    return [ "Arquivo indisponivel." ] unless readable_log?(path)

    File.open(path, "rb") do |file|
      buffer = +""
      position = file.size

      while position.positive? && buffer.count("\n") <= max_lines && buffer.bytesize < max_bytes
        chunk_size = [ 4096, position ].min
        position -= chunk_size
        file.seek(position)
        buffer.prepend(file.read(chunk_size).to_s)
      end

      sanitize_lines(buffer, max_lines)
    end
  rescue SystemCallError => e
    [ "Erro ao ler log: #{e.message}" ]
  end

  def sanitize_lines(buffer, max_lines)
    buffer
      .encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
      .lines
      .last(max_lines)
      .map(&:chomp)
  end
end
