# ActsAsMtObject

module ActiveRecord
  module Acts
    module ActsAsMtObject

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods

        def acts_as_mt_object(options = {}, &extension)
          options = {
            :mt_class   => self.to_s
          }.merge(options)

          class_variable_set(
            '@@mt_class', options[:mt_class].to_s.sub(/.*::/, '').downcase
          )

          send :include, ActiveRecord::Acts::ActsAsMtObject::ActMethods
        end

      end

      module ActMethods

        def self.included(base)
          basename    = base.class_variable_get('@@mt_class')
          table_name  = 'mt_' + basename
          primary_key = basename + '_id'

          custom_fields = []
          meta_fields = []

          base.class_eval do
            set_table_name  table_name
            set_primary_key primary_key

            imethods = instance_methods

            column_names.each do |column|
              prefix = basename + '_'
              short_name = column.sub(prefix, '')
              if ! imethods.include?(short_name.to_sym) && column != short_name
                define_method short_name do
                  send column
                end
              end
            end

            results = nil
            begin
              results = connection.execute(<<-__SQL__
SELECT field_basename, field_type, field_default FROM mt_field
WHERE field_obj_type = '#{basename}'
            __SQL__
              )
            rescue => e
            end
            if results
              results.each do |field|
                custom_fields << field
                if ! imethods.include?(field[0].to_sym)
                  define_method field[0] do
                    row = meta_values[('field.' + field[0]).to_sym]
                    if row
                      case field[1]
                      when 'text','select', 'radio', 'checkbox'
                        row[1]
                      when 'textarea'
                        row[9]
                      else
                        row.find{|v| v}
                      end
                    end || field[2]
                  end
                end
              end
            end
            class_variable_set('@@custom_fields', custom_fields)

            results = nil
            begin
              results = connection.execute(<<-__SQL__
SELECT #{basename}_meta_type FROM #{table_name}_meta
WHERE NOT #{basename}_meta_type LIKE 'field.%'
GROUP BY #{basename}_meta_type
            __SQL__
              )
            rescue => e
            end
            if results
              results.each do |field|
                meta_fields << field
                define_method field[0] do
                  row = meta_values[field[0].to_sym]
                  return row ? row.find{|v| v} : nil
                end
              end
            end
            class_variable_set('@@meta_fields', meta_fields)

            def meta_values
              if ! @meta_values
                @meta_values = {}
                if ! self.class.class_variable_get('@@custom_fields').blank? ||
                  ! self.class.class_variable_get('@@meta_fields').blank?

                  basename = self.class.class_variable_get('@@mt_class')
                  connection.execute(
                    "SELECT #{basename}_meta_type, " +
                    %W(
                      meta_vchar meta_vchar_idx meta_vdatetime
                      meta_vdatetime_idx meta_vinteger meta_vinteger_idx
                      meta_vfloat meta_vfloat_idx meta_vblob meta_vclob
                    ).map{|c| basename + '_' + c}.join(',') +
                    " FROM #{self.class.table_name}_meta " +
                    " WHERE #{basename}_meta_#{basename}_id = #{send self.class.primary_key}"
                  ).each do |row|
                    @meta_values[row.shift.to_sym] = row
                  end

                end
              end

              return @meta_values
            end

            def self.custom_field_names
              class_variable_get('@@custom_fields').map(&:first)
            end

            def self.meta_field_names
              class_variable_get('@@meta_fields').map(&:first)
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::Acts::ActsAsMtObject
