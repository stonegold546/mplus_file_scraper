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
  attribute :auto_collate, String

  validates_numericality_of :max_num_classes, greater_than_or_equal_to: 2,
                                              less_than_or_equal_to: 20
  validates :lca_inp_area, format: {
    with: /clas.*=.*c.*\(.*\d+.*\)/i
  }
  validates :lca_inp_area, format: {
    with: /data.*:.*\s*?FILE\s?I?S?\s?.*.(dat|txt)/i
  }
  validates_inclusion_of :mplus_type, in: %w[mplus mpdemo]
  validates_inclusion_of :sys_os, in: %w[windows unix]
  validates_inclusion_of :auto_collate, in: %w[yes no]

  def dat_file
    lca_inp_area.scan(/data.*:.*\s*?FILE\s?I?S?=?\s?(.*.(dat|txt))/i)[0][0]
                .strip
  end

  def min_classes
    lca_inp_area.scan(/clas.*=.*c.*\(.*\d+.*\)/i)[0].scan(/\d+/)[0].to_i
  end
end
