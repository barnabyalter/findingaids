require 'spec_helper'

describe CatalogController do

  def assigns_response
    @controller.instance_variable_get("@response")
  end

  describe "#index" do
    it "should return some results" do
      get :index, :q => "bloch", :search_field => "all_fields"

      assigns_response.docs.size.should > 0
      assigns_response.facets.size.should > 0
    end
  end

end
