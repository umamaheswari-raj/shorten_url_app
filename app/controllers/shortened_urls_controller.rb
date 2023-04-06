class ShortenedUrlsController < ApplicationController

	before_action :find_url, only: [:show, :shortened]
	# skip_before_filter :verify_authenticity_token

	def index
		@url = ShortenedUrl.new
	end

	def show
		redirect_to @url.sanitize_url, allow_other_host: :true
	end

	def create
		@url = ShortenedUrl.new
		@url.original_url = params[:original_url]
		@url.sanitize
		if @url.new_url?
			if @url.save
				redirect_to shortened_path(short_url: @url.short_url)
				# redirect_to shortened_urls_shortened_path(short_url: @url.short_url)
			else
				flash[:error] = "Click the error below:"
				render 'index'
			end
		else
			flash[:notice] = "A shor link for this URL is already in our Database"
			redirect_to shortened_path(short_url: @url.find_duplicate.short_url)
			# redirect_to shortened_urls_shortened_path(short_url: @url.find_duplicate.short_url)
		end
	end

	def shortened
		@url = ShortenedUrl.find_by_short_url(params[:short_url])
		host = request.host_with_port
		@original_url = @url.sanitize_url
		@short_url = host + '/' + @url.short_url
	end

	def fetch_original_url
		fetch_url = ShortenedUrl.find_by_short_url(params[:short_url])
		redirect_to fetch_url.sanitize_url
	end

	private
	def find_url
		@url = ShortenedUrl.find_by_short_url(params[:short_url])
	end

	def url_params
		params.require(:url).permit(:original_url)
	end

end
