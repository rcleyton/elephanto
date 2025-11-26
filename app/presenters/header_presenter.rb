class HeaderPresenter
  attr_reader :title, :subtitle, :show_back_button, :show_new_deck_button, :show_profile_menu

  def initialize(view_context, options={})
    @view                 = view_context
    @title                = options[:title]
    @subtitle             = options[:subtitle]
    @show_back_button     = options[:show_back_button] || false
    @show_new_deck_button = options[:show_new_deck_button] || false
    @show_profile_menu    = options.fetch(:show_profile_menu, true)
  end

  def render
    @view.render partial: "shared/header", locals: locals
  end

  def locals
    { 
      title: title,  
      subtitle: subtitle,
      show_back_button: show_back_button,
      show_new_deck_button: show_new_deck_button,
      show_profile_menu: show_profile_menu
    }
  end
end
