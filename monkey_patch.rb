# encoding: utf-8
#test ri
require 'rest-client'
require 'nokogiri'
require 'digest'
require "base64"
require 'socket'

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

class StringAsHtml
  attr_accessor :html_content

  def initialize(html_content)
    @html_content=Nokogiri::HTML(html_content)
  end

  def css(key_word)
    @html_content.css(key_word)
  end

  def help
    "this is a parser based on Nokogiri"
  end

end



class StringAsUri
  attr_accessor :uri_address ,:cookies

  def initialize(uri_address)
    @uri_address = uri_address
  end

  def get
    response = RestClient.get self.uri_address
    response
  end

  alias_method :read , :get # make function READ as GET

  def post(payload,headers={})

    RestClient.post(
      @uri_address,
      payload,
      :headers=>headers,
      )



  end

end


class StringAsFile
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  # Default return abs_path with Program execute path
  # Return a NEW modified path , if give a base_path to replace the Program execute path
  def abs_path(base_path="")
    if base_path == ""
      File.absolute_path(@name)
    else
      File.join(base_path,@name)
    end
  end


  def read
    begin
      f=File.open(self.abs_path,"r")
      content = f.read
      f.close
      content
    rescue =>e
      puts "Error here!!!! #{e}"
      return nil
    end
  end


  def size
    begin
      File.size(self.abs_path)
    rescue =>e
      puts "Error here!!!! #{e}"
    end
  end


  def folders
    begin
      Dir.entries(self.abs_path).select do |v|
        abs_v=File.join(self.abs_path,v)
        File.directory?(abs_v) && v !="." && v != ".."
      end
    rescue =>e
      puts "Error here!!!! #{e}"
      return nil
    end
  end

#Input String as File , and return files for this File Folder
  def files
    Dir.entries(self.abs_path).select do |v|
      abs_v=File.join(self.abs_path,v)
      File.file?(abs_v)
    end
  end




  def write(content,w_option="w")
    File.open(self.abs_path,w_option) {|f| f.write content}
  end

end

class StringAsBase64
  attr_accessor :input_string

  def initialize(input_string)
    @input_string = input_string
  end

  def encode
    enc = Base64.encode64 @input_string
  end

  def decode
    plain = Base64.decode64 @input_string
  end
end

#=======================
class StringAsTCPServer
  attr_accessor :server

  #Noted in RUBY Initialize won't really return things
  def initialize(input_port)
    @input_port = input_port
  end

  def self.new(input_port)
    @input_port = input_port
    @server = TCPServer.new(@input_port)
  end

  
end

#=======================
class StringAsFolder
  def initialize(input_folder)
    @input_folder = input_folder
  end

  def files
    Dir.entries(self.abs_path).select do |v|
      abs_v=File.join(self.abs_path,v)
      File.file?(abs_v)
    end
  end

  def abs_files

    abs_files = Dir.entries(self.abs_path).map do |v|
      abs_v=File.join(self.abs_path,v)
    end

    abs_files.select do |v|
      File.file?(v)
    end
  end


  def abs_path(base_path="")
    if base_path == ""
      File.absolute_path(@input_folder)
    else
      File.join(base_path,@input_folder)
    end
  end


end

#=======================
class String 

  def folder
    return StringAsFolder.new(self)
  end

  def file
    return StringAsFile.new(self)  
  end

  def uri
    return StringAsUri.new(self)
  end

  alias_method :http , :uri
  alias_method :url , :uri
  alias_method :trim ,:strip

  def parser
    return StringAsHtml.new(self)
  end

  def file_exist?
    File.exist?(self)
  end


  def folder?
    File.directory?(self)
  end

  def file?
    File.file?(self)
  end



  def to_a
    #puts "===176==="
    #puts "\n".encoding
    #puts self.encoding
    self.split("\n")
  end

  alias_method :to_lines , :to_a # make function READ as GET

  def md5
    md5 = Digest::MD5.new
    md5.update(self)
    md5.hexdigest
  end

  def base64
    StringAsBase64.new(self)
  end

  def tcpserver
    StringAsTCPServer.new(self)
  end

  #encoding stuff , UTF-8  utf8  utf-8
  def to_utf8
    str=self
    str=str.encode("UTF-8")
    str.scrub!("") #remove invaild 

    str.gsub!("\0","") #remove \0 NULL in string
    return str
    #binding.pry

  end
end


class Array
  def boolean
    if self.size == 0
      return false
    else
      return true
    end
  end

  def to_s_pure
    string=self.to_s[2..-3]
  end

  def to_blocks(reg_start_line , reg_end_line)
    lines=self
    bool_block_start = false
    bool_block_end = false 
    
    blocks=[]
    block = []
    
    lines.each do |line|
      bool_block_start = true if line =~ reg_start_line
      if bool_block_start 
        block << line
        bool_block_end = true if line =~ reg_end_line
        if bool_block_end 
          blocks << block
          block =[]
          bool_block_end = false
          bool_block_start = false
        end
      end
    end

    return blocks
  end# end of def 


end