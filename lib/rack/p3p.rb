module Rack
  class P3p
    def initialize(app)
      @app = app
    end

    def call(env)
      response = @app.call(env)
      insert_p3p(response)
    end

  private
    def insert_p3p(response)
      if response.first == 304
        response[1].delete('Set-Cookie')
      else
        response[1].update('P3P' => 'policyref="/w3c/p3p.xml", CP="ALL CURa ADMa DEVa TAIa OUR BUS IND UNI COM NAV INT"')
      end
      response
    end
  end
end