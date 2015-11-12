require 'spec_helper'

describe Store do
  describe '.create' do
    it 'should not be valid without a name' do
      @store = Store.new
      expect(@store).to_not be_valid
    end

    it 'should not be valid without a category' do
      @store = Store.create
      expect(@store.errors[:category]).to include("can't be blank")
    end

    it "should increase its mall's revenue by 1000 when created" do
      @mall = Mall.create name: "123456", city: "Vancouver"
      @mall.stores.create name: "Store", category: "retail"
      expect(@mall.revenue).to eq(1000)
    end

    it 'should not increase mall revenue when updated' do
      @mall = Mall.create name: "123456", city: "Vancouver"
      @store = @mall.stores.create name: "Store", category: "retail"
      @store.name = "New Store Name"
      @store.save
      expect(@mall.revenue).to eq(1000)
    end

    it 'cannot be created if the mall is over capacity' do
      @mall = Mall.create name: "Mall1", city: "Vancouver"
      10.times do
        @mall.stores.create name: "Store", category: "Food"
      end
      @store = @mall.stores.create name: "Store", category: "Food"
      expect(@store.errors[:capacity]).to eq(["too many stores"])
    end
  end  
end