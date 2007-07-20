module ThoughtBot # :nodoc: 
  module Shoulda # :nodoc: 
    module ControllerTests # :nodoc:
      module HTML # :nodoc: all
        def self.included(other)
          other.class_eval do
            extend ThoughtBot::Shoulda::ControllerTests::HTML::ClassMethods
          end
        end
  
        module ClassMethods 
          def make_show_html_tests(res)
            context "on GET to :show" do
              setup do
                record = get_existing_record(res)
                parent_params = make_parent_params(res, record)
                get :show, parent_params.merge({ res.identifier => record.to_param })          
              end

              if res.denied.actions.include?(:show)
                should_not_assign_to res.object
                should_deny_html_request(res)
              else
                should_assign_to res.object          
                should_respond_with :success
                should_render_template :show
                should_not_set_the_flash
              end
            end
          end

          def make_edit_html_tests(res)
            context "on GET to :edit" do
              setup do
                @record = get_existing_record(res)
                parent_params = make_parent_params(res, @record)
                get :edit, parent_params.merge({ res.identifier => @record.to_param })          
              end
        
              if res.denied.actions.include?(:edit)
                should_not_assign_to res.object
                should_deny_html_request(res)
              else
                should_assign_to res.object                    
                should_respond_with :success
                should_render_template :edit
                should_not_set_the_flash

                should "set @#{res.object} to requested instance" do
                  assert_equal @record, assigns(res.object)
                end
          
                should "display a form" do
                  assert_select "form", true, "The template doesn't contain a <form> element"            
                end
              end
            end
          end

          def make_index_html_tests(res)
            context "on GET to :index" do
              setup do
                parent_params = make_parent_params(res)
                get(:index, parent_params)          
              end

              if res.denied.actions.include?(:index)
                should_not_assign_to res.object.to_s.pluralize
                should_deny_html_request(res)          
              else
                should_respond_with :success
                should_assign_to res.object.to_s.pluralize
                should_render_template :index
                should_not_set_the_flash
              end
            end
          end

          def make_new_html_tests(res)
            context "on GET to :new" do
              setup do
                parent_params = make_parent_params(res)
                get(:new, parent_params)          
              end

              if res.denied.actions.include?(:new)
                should_not_assign_to res.object
                should_deny_html_request(res)
              else
                should_respond_with :success
                should_assign_to res.object
                should_not_set_the_flash
                should_render_template :new
          
                should "display a form" do
                  assert_select "form", true, "The template doesn't contain a <form> element"            
                end
              end
            end
          end

          def make_destroy_html_tests(res)
            context "on DELETE to :destroy" do
              setup do
                @record = get_existing_record(res)
                parent_params = make_parent_params(res, @record)
                delete :destroy, parent_params.merge({ res.identifier => @record.to_param })
              end
        
              if res.denied.actions.include?(:destroy)
                should_deny_html_request(res)
          
                should "not destroy record" do
                  assert @record.reload
                end
              else
                should_set_the_flash_to res.destroy.flash

                should "redirect to #{res.destroy.redirect}" do
                  record = @record
                  assert_redirected_to eval(res.destroy.redirect, self.send(:binding), __FILE__, __LINE__), 
                                       "Flash: #{flash.inspect}"
                end
          
                should "destroy record" do
                  assert_raises(::ActiveRecord::RecordNotFound) { @record.reload }
                end
              end
            end
          end

          def make_create_html_tests(res)
            context "on POST to :create" do
              setup do
                parent_params = make_parent_params(res)
                @count = res.klass.count
                post :create, parent_params.merge(res.object => res.create.params)
              end
        
              if res.denied.actions.include?(:create)
                should_deny_html_request(res)
                should_not_assign_to res.object
          
                should "not create new record" do
                  assert_equal @count, res.klass.count
                end          
              else
                should_assign_to res.object
                should_set_the_flash_to res.create.flash

                should "not have errors on @#{res.object}" do
                  assert_equal [], assigns(res.object).errors.full_messages, "@#{res.object} has errors:"            
                end
          
                should "redirect to #{res.create.redirect}" do
                  record = assigns(res.object)
                  assert_redirected_to eval(res.create.redirect, self.send(:binding), __FILE__, __LINE__)
                end          
              end      
            end
          end

          def make_update_html_tests(res)
            context "on PUT to :update" do
              setup do
                @record = get_existing_record(res)
                parent_params = make_parent_params(res, @record)
                put :update, parent_params.merge(res.identifier => @record.to_param, res.object => res.update.params)
              end

              if res.denied.actions.include?(:update)
                should_not_assign_to res.object
                should_deny_html_request(res)
              else
                should_assign_to res.object

                should "not have errors on @#{res.object}" do
                  assert_equal [], assigns(res.object).errors.full_messages, "@#{res.object} has errors:"
                end
          
                should "redirect to #{res.update.redirect}" do
                  record = assigns(res.object)
                  assert_redirected_to eval(res.update.redirect, self.send(:binding), __FILE__, __LINE__)            
                end

                should_set_the_flash_to(res.update.flash)
              end
            end
          end

          def should_deny_html_request(res)
            should "be denied" do
              assert_html_denied(res)
            end
          end
        end

        def assert_html_denied(res)
          assert_redirected_to eval(res.denied.redirect, self.send(:binding), __FILE__, __LINE__), 
                               "Flash: #{flash.inspect}"
          assert_contains(flash.values, res.denied.flash)
        end
      end
    end
  end
end
