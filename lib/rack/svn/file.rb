require 'time'
require 'rack/utils'
require 'rack/mime'
require 'svn/client'

module Rack
  module Svn
    class File
      attr_accessor :root
      attr_accessor :path

      alias :to_path :path

      def initialize(root)
        @root = root
      end

      def call(env)
        dup._call(env)
      end

      F = ::File

      def _call(env)
        @branch_name = env['PATH_PREFIX'] || ""
        @path_info = Rack::Utils.unescape(env["PATH_INFO"])
        return forbidden  if @path_info.include? ".."

        @path = F.join(@root, @branch_name, @path_info)

        begin
          #if F.file?(@path) && F.readable?(@path)
          serving
          #else
          #raise Errno::EPERM
          #end
        rescue SystemCallError
          not_found
        end
      end

      def forbidden
        body = "Forbidden\n"
        [403, {"Content-Type" => "text/plain",
            "Content-Length" => body.size.to_s,
            "X-Cascade" => "pass"},
          [body]]
      end

      # NOTE:
      #   We check via File::size? whether this file provides size info
      #   via stat (e.g. /proc files often don't), otherwise we have to
      #   figure it out by reading the whole file into memory. And while
      #   we're at it we also use this as body then.

      def serving
        context   = ::Svn::Client::Context.new
        body      = context.cat(@path, "HEAD","HEAD")

        last_modified = nil
        size          = nil
        context.list(@path ,"HEAD","HEAD") do |name,dirent,lock,abs_path|
          size          = dirent.size
          last_modified = dirent.time2
        end

        [200, {
            "Last-Modified"  => last_modified.httpdate,
            "Content-Type"   => Rack::Mime.mime_type(F.extname(@path_info), 'text/plain'),
            "Content-Length" => size.to_s
          }, body]
      end

      def not_found
        body = "File not found: #{@path_info}\n"
        [404, {"Content-Type" => "text/plain",
            "Content-Length" => body.size.to_s,
            "X-Cascade" => "pass"},
          [body]]
      end

      def each
        context   = ::Svn::Client::Context.new
        body      = context.cat(@path, "HEAD","HEAD")
        StringIO.new(body, "rb") do |file|
          while part = file.read(8192)
            yield part
          end
        end
      end
    end
  end
end
