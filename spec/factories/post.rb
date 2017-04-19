FactoryGirl.define do
  factory :post do
    url 'example.com/image.jpg'
    tag 'dsb'

    factory :another_post do
      url 'example.com/another_image.jpg'
    end
  end
end
