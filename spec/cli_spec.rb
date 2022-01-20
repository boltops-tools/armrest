describe Armrest::CLI do
  describe "armrest" do
    it "version" do
      out = execute("exe/armrest version")
      expect(out).to be_a(String)
    end
  end
end
