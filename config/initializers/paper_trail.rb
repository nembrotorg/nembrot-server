PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version < ActiveRecord::Base
    serialize :tag_list
    serialize :instruction_list
  end
end
