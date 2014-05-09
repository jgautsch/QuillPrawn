require 'sinatra'
require 'prawn'
require 'json'
require 'pp'

configure { set :server, :puma }

get '/' do
	send_file 'index.html'
end

post '/document' do
	puts params
	hash = JSON.parse(params[:content])
	pp hash
	qp = QuillPrawn.new(hash)
	qp.generate
  # respond_with 200
end

class QuillPrawn < Prawn::Document

  def initialize(content)
    super()

    @content = content
  end

  def generate
  	span(450, :position => :center) do
  		formatted_text transformed_content
  		# content["ops"].each do |op|
  		# 	text op["value"]
  		# end
  	end

  	render_file "example_#{Time.now.to_s}.pdf"
  end

  def transformed_content
  	@content["ops"].map { |op| transform_op(op) }
  end

  def transform_op(op)
  	puts "transforming: #{op}"
  	hash = {}
  	styles = []
  	hash[:text] = op["value"]
  	styles << :underline if op["attributes"]["underline"]
  	styles << :bold if op["attributes"]["bold"]
  	styles << :italic if op["attributes"]["italic"]
  	if op["attributes"]["link"]
  		styles << :underline
  		hash[:color] = "0000EE"
  	end

  	if op["attributes"]["font"] == "monospace"
  		hash[:font] = "Courier"
  	end

  	if op["attributes"]["font"] == "serif"
  		hash[:font] = "Times-Roman"
  	end

  	hash[:styles] = styles
  	hash[:size] = op["attributes"]["size"].gsub("px","").to_i if op["attributes"]["size"]
  	hash
  end
end


# class QuillPrawn
# 	def initialize(content)
# 		@content = content
# 	end

# 	def transformed_content
# 		@content.map { |op| transform_op(op) }
# 	end

# 	def transform_op(op)
# 		hash = {}
# 		styles = []
# 		hash[:text] = op["value"]
# 		styles << :underline if op["attributes"]["underline"]
# 		styles << :bold if op["attributes"]["bold"]
# 		styles << :italic if op["attributes"]["italic"]
# 		hash[:styles] = styles
# 		hash[:size] = op["attributes"]["size"].gsub("px","").to_i if op["attributes"]["size"]
# 		hash
# 	end

# 	def print
# 		Prawn::Document.generate("implicit_#{Time.now.to_s}.pdf") do
# 			span(450, :position => :center) do
# 				formatted_text transformed_content
# 				# content["ops"].each do |op|
# 				# 	text op["value"]
# 				# end
# 			end
# 		end

# 		# formatted_text [ { :text => "Some bold. ", :styles => [:bold] },
# 		#  { :text => "Some italic. ", :styles => [:italic] },
# 		#  { :text => "Bold italic. ", :styles => [:bold, :italic] },
# 		#  { :text => "Bigger Text. ", :size => 20 },
# 		#  { :text => "More spacing. ", :character_spacing => 3 },
# 		#  { :text => "Different Font. ", :font => "Courier" },
# 		#  { :text => "Some coloring. ", :color => "FF00FF" },
# 		#  { :text => "Link to the wiki. ",
# 		#  :color => "0000FF",
# 		#  :link => "https://github.com/prawnpdf/prawn/wiki" },
# 		#  { :text => "Link to a local file. ",
# 		#  :color => "0000FF",
# 		#  :local => "./local_file.txt" }
# 		#  ]

# 	end
# end