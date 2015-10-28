require "sinatra"
require "launchy"
require "deklarativna"
require "thin"
require "contentful_bootstrap/constants"
require "contentful_bootstrap/token"

module ContentfulBootstrap
  class OAuthEchoView < BaseTemplate
    def _body
      script(type: "text/javascript") {
        <<-JS
          (function() {
            var access_token = window.location.hash.split('&')[0].split('=')[1];
            window.location.replace('http://localhost:5123/save_token/' + access_token);
          })();
        JS
      }
    end
  end

  class ThanksView < BaseTemplate
    def _head
      link(rel: "stylesheet", href: "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css")
    end

    def _body
      div(class: "container") {
        div(class: "jumbotron") {[
          h1 { "Contentful Bootstrap" },
          h4 { "Thanks! The OAuth Token has been generated" },
          p { "The Space you specified will now start to create. You can close this window freely" }
        ]}
      }
    end
  end

  class Server < Sinatra::Base
    configure do
      set :port, 5123
      set :logging, nil
      set :quiet, true
      Thin::Logging.silent = true # Silence Thin startup message
    end

    get '/' do
      client_id = ContentfulBootstrap::Constants::OAUTH_APP_ID
      redirect_uri = ContentfulBootstrap::Constants::OAUTH_CALLBACK_URL
      scope = "content_management_manage"
      Launchy.open("https://be.contentful.com/oauth/authorize?response_type=token&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}")
      ""
    end

    get '/oauth_callback' do
      OAuthEchoView.new.render
    end

    get '/save_token/:token' do
      Token.write(params[:token])
      ThanksView.new.render
    end
  end
end
