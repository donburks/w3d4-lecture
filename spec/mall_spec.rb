require_relative 'spec_helper'

describe Mall do
  describe 'validations' do
    it 'should not be valid without a name' do
      @mall = Mall.create
      expect(@mall.errors[:name]).to include("can't be blank")
    end

    it 'should not be valid with a short name' do
      @mall = Mall.create name: "foo"
      expect(@mall.errors[:name]).to include("is too short (minimum is 5 characters)")
    end

    it 'should have a valid name with a name greater than 5 characters' do
      @mall = Mall.create name: "Pacific Centre"
      expect(@mall.errors[:name]).to eq([])
    end

    it 'should not be valid without a city' do
      @mall = Mall.create
      expect(@mall.errors[:city]).to include("can't be blank")
    end

    it 'should be valid with a name longer than 5 characters and a city' do
      @mall = Mall.create name: "Pacific Centre", city: "Vancouver"
      expect(@mall).to be_valid
    end
  end

  describe 'associations' do
    it 'should be able to list its stores' do
      @mall = Mall.create name: "Pacific Centre", city: "Vancouver"
      expect{@mall.stores}.to_not raise_error
    end
  end

  describe '#destroy' do
    it 'should destroy its stores when destroyed' do
      @mall = Mall.create name: "Mall2", city: "Vancouver"
      @mall.stores.create name: "Store", category: "blah"
      @mall.destroy
      expect(Store.count).to eq(0)
    end
  end

  describe '#capacity' do
    it 'should have a default capacity of 10 stores' do
      @mall = Mall.create name: "Mall1", city: "Vancouver"
      expect(@mall.capacity).to eq(10)
    end
  end
end