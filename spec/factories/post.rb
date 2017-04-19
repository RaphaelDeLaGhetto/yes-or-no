FactoryGirl.define do
  factory :post do
    url 'http://example.com/image.jpg'
    tag 'dsb'

    factory :another_post do
      url 'http://example.com/another_image.jpg'
    end
  end
end
