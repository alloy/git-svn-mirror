require File.expand_path("../spec_helper", __FILE__)

describe "GitSVNMirror, concerning `init'" do
  before do
    @mirror = GitSVNMirror.new
  end

  it "does something" do
    @mirror.init(%w{})
  end
end
