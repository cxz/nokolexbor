require 'spec_helper'

describe Nokolexbor::Attribute do
  before do
    @doc = Nokolexbor::HTML('<div attr1=1 attr2=2 attr3=3></div>')
    @node = @doc.at_css('div')
  end

  it 'new' do
    att = Nokolexbor::Attribute.new(@doc, "a1");
    _(att.name).must_equal 'a1'
    _(att.value).must_equal ''
    _(att.document).must_be_instance_of Nokolexbor::Document
  end

  it 'should be of correct class' do
    _(@node.attribute('attr1')).must_be_instance_of Nokolexbor::Attribute
  end

  it 'name' do
    _(@node.attribute('attr1').name).must_equal 'attr1'
  end

  it 'name=' do
    @node.attribute('attr1').name = 'new1'
    _(@node.to_html).must_equal '<div new1="1" attr2="2" attr3="3"></div>'
  end

  it 'value' do
    a = @node.attribute('attr1')
    [:value, :to_s, :to_str, :text, :content].each do |method|
      _(a.send(method)).must_equal '1'
    end
  end

  it 'value=' do
    @node.attribute('attr1').value = 'new1'
    _(@node.to_html).must_equal '<div attr1="new1" attr2="2" attr3="3"></div>'
  end

end