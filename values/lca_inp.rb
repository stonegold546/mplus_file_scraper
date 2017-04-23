require 'virtus'
require 'active_model'

# Value object for LCA Input syntax
class LcaInpVal
  include Virtus.model
  include ActiveModel::Validations

  attribute :max_num_classes, Integer
  attribute :lca_inp_area, String
  attribute :mplus_type, String
  attribute :sys_os, String

  validates_numericality_of :max_num_classes, greater_than_or_equal_to: 2,
                                              less_than_or_equal_to: 20
  validates :lca_inp_area, format: {
    with: /clas.*=.*c.*\(.*\d+.*\)/i
  }
  validates :lca_inp_area, format: {
    with: /data.*:.*FILE\s?I?S?\s?.*.dat/i
  }
  validates_inclusion_of :mplus_type, in: %w(mplus mpdemo)
  validates_inclusion_of :sys_os, in: %w(windows unix)
end