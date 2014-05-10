require 'sinatra'
require 'prawn'
require 'json'
require 'pp'

configure { set :server, :puma }

get '/' do
	send_file 'index.html'
end

post '/document' do
	content = JSON.parse(params[:content])
	qp = QuillPrawn.new(content)
	qp.generate
end

class Transformer

	def initialize(op)
		@op = op
		set_value
		build_styles
		add_links
		set_font
		set_size
	end

	
	def to_hash
		@content_object
	end

	
	def set_value
		@content_object = {text: @op["value"]}
	end

	
	def build_styles
		@styles = []
		@styles << :underline if @op["attributes"]["underline"]
		@styles << :bold 			if @op["attributes"]["bold"]
		@styles << :italic 		if @op["attributes"]["italic"]
		@content_object[:styles] = @styles
	end

	
	def add_links
		if @op["attributes"]["link"]
			@content_object[:styles] = @content_object[:styles] << :underline
			@content_object[:color] = "0000EE"
		end
	end

	
	def set_font
		case @op["attributes"]["font"]
		when "monospace"
			@content_object[:font] = "Courier"
		when "serif"
			@content_object[:font] = "Times-Roman"
		end
	end

	
	def set_size
		if @op["attributes"]["size"]
			@content_object[:size] = @op["attributes"]["size"].gsub("px","").to_i 
		end
	end
end



class QuillPrawn < Prawn::Document

  def initialize(content)
    super()
    @content = content
  end


  def generate
  	span(450, :position => :center) do
  		formatted_text transformed_content
  	end
  	render_file "example_#{Time.now.to_s}.pdf"
  end


  def transformed_content
  	@content["ops"].map { |op| Transformer.new(op).to_hash }
  end
end