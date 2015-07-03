class PlantTrialSubmissionDecorator < SubmissionDecorator
  delegate_all

  def label
    h.content_tag(
      :span,
      ''.tap do |l|
        l << plant_trial_name if plant_trial_name
        l << " (#{species_name})" if species_name
        l << I18n.t('submission.empty_label') unless plant_trial_name || species_name
      end.strip,
      class: 'title'
    )
  end

  def further_details
    ''.tap do |l|
      l << h.content_tag(:span, project_descriptor, class: 'details')
      if trait_descriptors.present?
        l << h.content_tag(:span, 'Traits scored: ', class: 'text')
        l << h.content_tag(:span, trait_descriptors.join(" | "), class: 'details')
      end
    end.strip
  end

  def plant_trial_name
    @plant_trial_name ||= object.content.step01.plant_trial_name.presence
  end

  def project_descriptor
    @project_descriptor ||= object.content.step01.project_descriptor.presence
  end

  def species_name
    plant_population.try(:taxonomy_term).try(:name)
  end

  def plant_population
    return @plant_population if defined?(@plant_population)
    return if ! object.content.step01.plant_population_id
    @plant_population = PlantPopulation.find(object.content.step01.plant_population_id)
  end

  def trait_descriptors
    object.content.step02.trait_descriptor_list.try(:select, &:present?)
  end

  # def trait_names
  #   trait_descriptors.map(&:descriptor_name)
  # end

  def plant_trial_description
    object.content.step01.plant_trial_description
  end

  def trial_year
    object.content.step01.trial_year
  end

  def country_name
    country_id = object.content.step01.country_id
    return unless country_id.present?
    Country.find(country_id).country_name
  end

  def institute_id
    object.content.step01.institute_id
  end

  def trial_location_site_name
    object.content.step01.trial_location_site_name
  end

  def place_name
    object.content.step01.place_name
  end

  def latitude
    object.content.step01.latitude
  end

  def longitude
    object.content.step01.longitude
  end

  def altitude
    alt = object.content.step01.altitude
    return unless alt.present?
    "#{alt} m"
  end

  def terrain
    object.content.step01.terrain
  end

  def soil_type
    object.content.step01.soil_type
  end

  def statistical_factors
    object.content.step01.statistical_factors
  end

  def design_factors
    object.content.step01.design_factors
  end

  def data_owned_by
    object.content.step04.data_owned_by.presence
  end

  def data_provenance
    object.content.step04.data_provenance.presence
  end

  def comments
    object.content.step04.comments.presence
  end
end