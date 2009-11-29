require File.dirname(__FILE__) + '/../test_helper'

class NiceAssetExtensionTest < Test::Unit::TestCase
  
  # Replace this with your real tests.
  def test_this_extension
    flunk
  end
  
  def test_initialization
    assert_equal RADIANT_ROOT + '/vendor/extensions/nice_asset', NiceAssetExtension.root
    assert_equal 'Nice Asset', NiceAssetExtension.extension_name
  end
  
end
