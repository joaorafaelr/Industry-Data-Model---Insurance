USE InsuranceData;
GO

/* Consolidated foreign-key relationships to run after base table creation */

-- Relationships from 01_CoreEntities.sql
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rpp_country' AND parent_object_id = OBJECT_ID('core.ref_postcode_pattern'))
ALTER TABLE core.ref_postcode_pattern
  ADD CONSTRAINT FK_rpp_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_class' AND parent_object_id = OBJECT_ID('core.entity'))
ALTER TABLE core.entity
  ADD CONSTRAINT FK_entity_class FOREIGN KEY (entity_class_code) REFERENCES core.ref_entity_class(entity_class_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_name_entity' AND parent_object_id = OBJECT_ID('core.entity_name'))
ALTER TABLE core.entity_name
  ADD CONSTRAINT FK_entity_name_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_addr_entity' AND parent_object_id = OBJECT_ID('core.entity_address'))
ALTER TABLE core.entity_address
  ADD CONSTRAINT FK_entity_addr_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_addr_usage' AND parent_object_id = OBJECT_ID('core.entity_address'))
ALTER TABLE core.entity_address
  ADD CONSTRAINT FK_entity_addr_usage FOREIGN KEY (address_usage_code) REFERENCES core.ref_address_usage(address_usage_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_addr_country' AND parent_object_id = OBJECT_ID('core.entity_address'))
ALTER TABLE core.entity_address
  ADD CONSTRAINT FK_entity_addr_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ecp_entity' AND parent_object_id = OBJECT_ID('core.entity_contact_point'))
ALTER TABLE core.entity_contact_point
  ADD CONSTRAINT FK_ecp_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ecp_type' AND parent_object_id = OBJECT_ID('core.entity_contact_point'))
ALTER TABLE core.entity_contact_point
  ADD CONSTRAINT FK_ecp_type FOREIGN KEY (contact_type_code) REFERENCES core.ref_contact_type(contact_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ecp_purpose' AND parent_object_id = OBJECT_ID('core.entity_contact_point'))
ALTER TABLE core.entity_contact_point
  ADD CONSTRAINT FK_ecp_purpose FOREIGN KEY (purpose_code) REFERENCES core.ref_contact_purpose(purpose_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_eid_entity' AND parent_object_id = OBJECT_ID('core.entity_identity'))
ALTER TABLE core.entity_identity
  ADD CONSTRAINT FK_eid_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_eid_type' AND parent_object_id = OBJECT_ID('core.entity_identity'))
ALTER TABLE core.entity_identity
  ADD CONSTRAINT FK_eid_type FOREIGN KEY (identity_type_code) REFERENCES core.ref_identity_type(identity_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_eid_country' AND parent_object_id = OBJECT_ID('core.entity_identity'))
ALTER TABLE core.entity_identity
  ADD CONSTRAINT FK_eid_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_esk_entity' AND parent_object_id = OBJECT_ID('core.entity_source_key'))
ALTER TABLE core.entity_source_key
  ADD CONSTRAINT FK_esk_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_nat_entity' AND parent_object_id = OBJECT_ID('core.entity_nationality'))
ALTER TABLE core.entity_nationality
  ADD CONSTRAINT FK_entity_nat_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_nat_country' AND parent_object_id = OBJECT_ID('core.entity_nationality'))
ALTER TABLE core.entity_nationality
  ADD CONSTRAINT FK_entity_nat_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_class_entity' AND parent_object_id = OBJECT_ID('core.entity_classification'))
ALTER TABLE core.entity_classification
  ADD CONSTRAINT FK_entity_class_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_class_code' AND parent_object_id = OBJECT_ID('core.entity_classification'))
ALTER TABLE core.entity_classification
  ADD CONSTRAINT FK_entity_class_code FOREIGN KEY (classification_code) REFERENCES core.ref_entity_classification(classification_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_company_entity' AND parent_object_id = OBJECT_ID('core.entity_company_membership'))
ALTER TABLE core.entity_company_membership
  ADD CONSTRAINT FK_entity_company_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_company_code' AND parent_object_id = OBJECT_ID('core.entity_company_membership'))
ALTER TABLE core.entity_company_membership
  ADD CONSTRAINT FK_entity_company_code FOREIGN KEY (company_code) REFERENCES core.ref_company(company_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_network_entity' AND parent_object_id = OBJECT_ID('core.entity_network_membership'))
ALTER TABLE core.entity_network_membership
  ADD CONSTRAINT FK_entity_network_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_network_code' AND parent_object_id = OBJECT_ID('core.entity_network_membership'))
ALTER TABLE core.entity_network_membership
  ADD CONSTRAINT FK_entity_network_code FOREIGN KEY (network_code) REFERENCES core.ref_network(network_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_tax_entity' AND parent_object_id = OBJECT_ID('core.entity_tax_regime'))
ALTER TABLE core.entity_tax_regime
  ADD CONSTRAINT FK_entity_tax_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_tax_code' AND parent_object_id = OBJECT_ID('core.entity_tax_regime'))
ALTER TABLE core.entity_tax_regime
  ADD CONSTRAINT FK_entity_tax_code FOREIGN KEY (tax_regime_code) REFERENCES core.ref_tax_regime(tax_regime_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_entity_tax_country' AND parent_object_id = OBJECT_ID('core.entity_tax_regime'))
ALTER TABLE core.entity_tax_regime
  ADD CONSTRAINT FK_entity_tax_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_consent_entity' AND parent_object_id = OBJECT_ID('core.consent'))
ALTER TABLE core.consent
  ADD CONSTRAINT FK_consent_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_consent_purpose' AND parent_object_id = OBJECT_ID('core.consent'))
ALTER TABLE core.consent
  ADD CONSTRAINT FK_consent_purpose FOREIGN KEY (consent_purpose_code) REFERENCES core.ref_consent_purpose(consent_purpose_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_eel_entity' AND parent_object_id = OBJECT_ID('core.entity_event_log'))
ALTER TABLE core.entity_event_log
  ADD CONSTRAINT FK_eel_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_kyc_entity' AND parent_object_id = OBJECT_ID('core.kyc_status'))
ALTER TABLE core.kyc_status
  ADD CONSTRAINT FK_kyc_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_kyc_regime' AND parent_object_id = OBJECT_ID('core.kyc_status'))
ALTER TABLE core.kyc_status
  ADD CONSTRAINT FK_kyc_regime FOREIGN KEY (kyc_regime_code) REFERENCES core.ref_kyc_regime(kyc_regime_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rrc_role' AND parent_object_id = OBJECT_ID('core.role_ref_capability'))
ALTER TABLE core.role_ref_capability
  ADD CONSTRAINT FK_rrc_role FOREIGN KEY (role_code, context_code) REFERENCES core.role_ref(role_code, context_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rrc_cap' AND parent_object_id = OBJECT_ID('core.role_ref_capability'))
ALTER TABLE core.role_ref_capability
  ADD CONSTRAINT FK_rrc_cap FOREIGN KEY (capability_code) REFERENCES core.role_capability(capability_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_er_from_entity' AND parent_object_id = OBJECT_ID('core.entity_relationship'))
ALTER TABLE core.entity_relationship
  ADD CONSTRAINT FK_er_from_entity FOREIGN KEY (from_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_er_to_entity' AND parent_object_id = OBJECT_ID('core.entity_relationship'))
ALTER TABLE core.entity_relationship
  ADD CONSTRAINT FK_er_to_entity FOREIGN KEY (to_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_er_rel' AND parent_object_id = OBJECT_ID('core.entity_relationship'))
ALTER TABLE core.entity_relationship
  ADD CONSTRAINT FK_er_rel FOREIGN KEY (relationship_code, context_code) REFERENCES core.relationship_ref(relationship_code, context_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_policy_lob' AND parent_object_id = OBJECT_ID('core.policy'))
ALTER TABLE core.policy
  ADD CONSTRAINT FK_policy_lob FOREIGN KEY (lob_code) REFERENCES core.ref_lob(lob_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ppr_policy' AND parent_object_id = OBJECT_ID('core.entity_policy_role'))
ALTER TABLE core.entity_policy_role
  ADD CONSTRAINT FK_ppr_policy FOREIGN KEY (policy_id) REFERENCES core.policy(policy_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ppr_entity' AND parent_object_id = OBJECT_ID('core.entity_policy_role'))
ALTER TABLE core.entity_policy_role
  ADD CONSTRAINT FK_ppr_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ppr_role' AND parent_object_id = OBJECT_ID('core.entity_policy_role'))
ALTER TABLE core.entity_policy_role
  ADD CONSTRAINT FK_ppr_role FOREIGN KEY (role_code, context_code) REFERENCES core.role_ref(role_code, context_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_per_policy' AND parent_object_id = OBJECT_ID('core.policy_entity_relationship'))
ALTER TABLE core.policy_entity_relationship
  ADD CONSTRAINT FK_per_policy FOREIGN KEY (policy_id) REFERENCES core.policy(policy_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_per_parent' AND parent_object_id = OBJECT_ID('core.policy_entity_relationship'))
ALTER TABLE core.policy_entity_relationship
  ADD CONSTRAINT FK_per_parent FOREIGN KEY (parent_ppr_id) REFERENCES core.entity_policy_role(entity_policy_role_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_per_child' AND parent_object_id = OBJECT_ID('core.policy_entity_relationship'))
ALTER TABLE core.policy_entity_relationship
  ADD CONSTRAINT FK_per_child FOREIGN KEY (child_ppr_id) REFERENCES core.entity_policy_role(entity_policy_role_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_per_rel' AND parent_object_id = OBJECT_ID('core.policy_entity_relationship'))
ALTER TABLE core.policy_entity_relationship
  ADD CONSTRAINT FK_per_rel FOREIGN KEY (relationship_code, context_code) REFERENCES core.relationship_ref(relationship_code, context_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_dsr_entity' AND parent_object_id = OBJECT_ID('core.entity_dsr_event'))
ALTER TABLE core.entity_dsr_event
  ADD CONSTRAINT FK_dsr_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_pc_scope_ppr' AND parent_object_id = OBJECT_ID('pc.entity_scope'))
ALTER TABLE pc.entity_scope
  ADD CONSTRAINT FK_pc_scope_ppr FOREIGN KEY (entity_policy_role_id) REFERENCES core.entity_policy_role(entity_policy_role_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_lp_scope_ppr' AND parent_object_id = OBJECT_ID('lp.entity_scope'))
ALTER TABLE lp.entity_scope
  ADD CONSTRAINT FK_lp_scope_ppr FOREIGN KEY (entity_policy_role_id) REFERENCES core.entity_policy_role(entity_policy_role_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_hlth_scope_ppr' AND parent_object_id = OBJECT_ID('hlth.entity_scope'))
ALTER TABLE hlth.entity_scope
  ADD CONSTRAINT FK_hlth_scope_ppr FOREIGN KEY (entity_policy_role_id) REFERENCES core.entity_policy_role(entity_policy_role_id);
GO

-- Relationships from 02_Intermediaries.sql
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_int_entity' AND parent_object_id = OBJECT_ID('cid.cid_int_intermediary'))
ALTER TABLE cid.cid_int_intermediary
  ADD CONSTRAINT FK_cid_int_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_int_home_country' AND parent_object_id = OBJECT_ID('cid.cid_int_intermediary'))
ALTER TABLE cid.cid_int_intermediary
  ADD CONSTRAINT FK_cid_int_home_country FOREIGN KEY (home_country_code) REFERENCES core.ref_country(country_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_isk_intermediary' AND parent_object_id = OBJECT_ID('cid.cid_int_intermediary_source_key'))
ALTER TABLE cid.cid_int_intermediary_source_key
  ADD CONSTRAINT FK_cid_isk_intermediary FOREIGN KEY (intermediary_id) REFERENCES cid.cid_int_intermediary(intermediary_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_rep_intermediary' AND parent_object_id = OBJECT_ID('cid.cid_int_intermediary_rep'))
ALTER TABLE cid.cid_int_intermediary_rep
  ADD CONSTRAINT FK_cid_rep_intermediary FOREIGN KEY (intermediary_id) REFERENCES cid.cid_int_intermediary(intermediary_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_rep_person' AND parent_object_id = OBJECT_ID('cid.cid_int_intermediary_rep'))
ALTER TABLE cid.cid_int_intermediary_rep
  ADD CONSTRAINT FK_cid_rep_person FOREIGN KEY (person_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_license_intermediary' AND parent_object_id = OBJECT_ID('cid.cid_int_intermediary_license'))
ALTER TABLE cid.cid_int_intermediary_license
  ADD CONSTRAINT FK_cid_license_intermediary FOREIGN KEY (intermediary_id) REFERENCES cid.cid_int_intermediary(intermediary_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_license_juris' AND parent_object_id = OBJECT_ID('cid.cid_int_intermediary_license'))
ALTER TABLE cid.cid_int_intermediary_license
  ADD CONSTRAINT FK_cid_license_juris FOREIGN KEY (jurisdiction_id) REFERENCES cid.cid_int_ref_jurisdiction(jurisdiction_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_license_lob' AND parent_object_id = OBJECT_ID('cid.cid_int_intermediary_license'))
ALTER TABLE cid.cid_int_intermediary_license
  ADD CONSTRAINT FK_cid_license_lob FOREIGN KEY (lob_scope_code) REFERENCES cid.cid_int_ref_lob_scope(lob_scope_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_appt_intermediary' AND parent_object_id = OBJECT_ID('cid.cid_int_appointment'))
ALTER TABLE cid.cid_int_appointment
  ADD CONSTRAINT FK_cid_appt_intermediary FOREIGN KEY (intermediary_id) REFERENCES cid.cid_int_intermediary(intermediary_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_appt_insurer' AND parent_object_id = OBJECT_ID('cid.cid_int_appointment'))
ALTER TABLE cid.cid_int_appointment
  ADD CONSTRAINT FK_cid_appt_insurer FOREIGN KEY (insurer_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_appt_type' AND parent_object_id = OBJECT_ID('cid.cid_int_appointment'))
ALTER TABLE cid.cid_int_appointment
  ADD CONSTRAINT FK_cid_appt_type FOREIGN KEY (appointment_type_id) REFERENCES cid.cid_int_ref_appointment_type(appointment_type_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_appt_license' AND parent_object_id = OBJECT_ID('cid.cid_int_appointment'))
ALTER TABLE cid.cid_int_appointment
  ADD CONSTRAINT FK_cid_appt_license FOREIGN KEY (license_id) REFERENCES cid.cid_int_intermediary_license(license_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_fp_subject' AND parent_object_id = OBJECT_ID('cid.cid_int_fit_proper'))
ALTER TABLE cid.cid_int_fit_proper
  ADD CONSTRAINT FK_cid_fp_subject FOREIGN KEY (subject_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_remas_ppr' AND parent_object_id = OBJECT_ID('cid.cid_int_remuneration_assignment'))
ALTER TABLE cid.cid_int_remuneration_assignment
  ADD CONSTRAINT FK_cid_remas_ppr FOREIGN KEY (entity_policy_role_id) REFERENCES core.entity_policy_role(entity_policy_role_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_remas_tpl' AND parent_object_id = OBJECT_ID('cid.cid_int_remuneration_assignment'))
ALTER TABLE cid.cid_int_remuneration_assignment
  ADD CONSTRAINT FK_cid_remas_tpl FOREIGN KEY (template_id) REFERENCES cid.cid_int_remuneration_template(template_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_bor_from' AND parent_object_id = OBJECT_ID('cid.cid_int_broker_of_record_change'))
ALTER TABLE cid.cid_int_broker_of_record_change
  ADD CONSTRAINT FK_cid_bor_from FOREIGN KEY (from_ppr_id) REFERENCES core.entity_policy_role(entity_policy_role_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_bor_to' AND parent_object_id = OBJECT_ID('cid.cid_int_broker_of_record_change'))
ALTER TABLE cid.cid_int_broker_of_record_change
  ADD CONSTRAINT FK_cid_bor_to FOREIGN KEY (to_ppr_id) REFERENCES core.entity_policy_role(entity_policy_role_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_mem_entity' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_membership'))
ALTER TABLE cid.cid_ch_channel_membership
  ADD CONSTRAINT FK_cid_ch_mem_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

-- Relationships from 03_Channels.sql
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_channel_code' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel'))
ALTER TABLE cid.cid_ch_channel
  ADD CONSTRAINT FK_cid_ch_channel_code FOREIGN KEY (channel_code) REFERENCES cid.cid_ch_ref_channel(channel_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_channel_owner' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel'))
ALTER TABLE cid.cid_ch_channel
  ADD CONSTRAINT FK_cid_ch_channel_owner FOREIGN KEY (owner_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_channel_intermediary' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel'))
ALTER TABLE cid.cid_ch_channel
  ADD CONSTRAINT FK_cid_ch_channel_intermediary FOREIGN KEY (intermediary_id) REFERENCES cid.cid_int_intermediary(intermediary_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_avail_channel' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_availability'))
ALTER TABLE cid.cid_ch_channel_availability
  ADD CONSTRAINT FK_cid_ch_avail_channel FOREIGN KEY (channel_id) REFERENCES cid.cid_ch_channel(channel_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_avail_product' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_availability'))
ALTER TABLE cid.cid_ch_channel_availability
  ADD CONSTRAINT FK_cid_ch_avail_product FOREIGN KEY (product_family_code) REFERENCES core.ref_product_family(product_family_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_avail_country' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_availability'))
ALTER TABLE cid.cid_ch_channel_availability
  ADD CONSTRAINT FK_cid_ch_avail_country FOREIGN KEY (country_code) REFERENCES core.ref_country(country_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_avail_juris' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_availability'))
ALTER TABLE cid.cid_ch_channel_availability
  ADD CONSTRAINT FK_cid_ch_avail_juris FOREIGN KEY (jurisdiction_id) REFERENCES cid.cid_int_ref_jurisdiction(jurisdiction_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_avail_stage' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_availability'))
ALTER TABLE cid.cid_ch_channel_availability
  ADD CONSTRAINT FK_cid_ch_avail_stage FOREIGN KEY (lifecycle_stage_code) REFERENCES cid.cid_ch_ref_lifecycle_stage(lifecycle_stage_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_avail_reason' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_availability'))
ALTER TABLE cid.cid_ch_channel_availability
  ADD CONSTRAINT FK_cid_ch_avail_reason FOREIGN KEY (reason_code) REFERENCES cid.cid_ch_ref_availability_reason(reason_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_gov_channel' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_governance'))
ALTER TABLE cid.cid_ch_channel_governance
  ADD CONSTRAINT FK_cid_ch_gov_channel FOREIGN KEY (channel_id) REFERENCES cid.cid_ch_channel(channel_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_gov_stage' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_governance'))
ALTER TABLE cid.cid_ch_channel_governance
  ADD CONSTRAINT FK_cid_ch_gov_stage FOREIGN KEY (lifecycle_stage_code) REFERENCES cid.cid_ch_ref_lifecycle_stage(lifecycle_stage_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_gov_decider' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_governance'))
ALTER TABLE cid.cid_ch_channel_governance
  ADD CONSTRAINT FK_cid_ch_gov_decider FOREIGN KEY (decided_by_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ch_mem_channel' AND parent_object_id = OBJECT_ID('cid.cid_ch_channel_membership'))
ALTER TABLE cid.cid_ch_channel_membership
  ADD CONSTRAINT FK_cid_ch_mem_channel FOREIGN KEY (channel_id) REFERENCES cid.cid_ch_channel(channel_id);
GO

-- Relationships from 04_Customer_Interaction.sql
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_edp_entity' AND parent_object_id = OBJECT_ID('core.entity_digital_profile'))
ALTER TABLE core.entity_digital_profile
  ADD CONSTRAINT FK_edp_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_edp_segment' AND parent_object_id = OBJECT_ID('core.entity_digital_profile'))
ALTER TABLE core.entity_digital_profile
  ADD CONSTRAINT FK_edp_segment FOREIGN KEY (digital_segment_code) REFERENCES core.ref_digital_segment(digital_segment_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_campaign_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_campaign'))
ALTER TABLE cid.cid_ci_campaign
  ADD CONSTRAINT FK_cid_ci_campaign_type FOREIGN KEY (campaign_type_code) REFERENCES cid.cid_ci_ref_campaign_type(campaign_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_campaign_owner' AND parent_object_id = OBJECT_ID('cid.cid_ci_campaign'))
ALTER TABLE cid.cid_ci_campaign
  ADD CONSTRAINT FK_cid_ci_campaign_owner FOREIGN KEY (owner_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_campaign_channel' AND parent_object_id = OBJECT_ID('cid.cid_ci_campaign'))
ALTER TABLE cid.cid_ci_campaign
  ADD CONSTRAINT FK_cid_ci_campaign_channel FOREIGN KEY (primary_channel_id) REFERENCES cid.cid_ch_channel(channel_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_campaign_objective' AND parent_object_id = OBJECT_ID('cid.cid_ci_campaign'))
ALTER TABLE cid.cid_ci_campaign
  ADD CONSTRAINT FK_cid_ci_campaign_objective FOREIGN KEY (objective_code) REFERENCES cid.cid_ci_ref_objective(objective_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_campmem_campaign' AND parent_object_id = OBJECT_ID('cid.cid_ci_campaign_membership'))
ALTER TABLE cid.cid_ci_campaign_membership
  ADD CONSTRAINT FK_cid_ci_campmem_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_campmem_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_campaign_membership'))
ALTER TABLE cid.cid_ci_campaign_membership
  ADD CONSTRAINT FK_cid_ci_campmem_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_camp_out_campaign' AND parent_object_id = OBJECT_ID('cid.cid_ci_campaign_outcome'))
ALTER TABLE cid.cid_ci_campaign_outcome
  ADD CONSTRAINT FK_cid_ci_camp_out_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_camp_out_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_campaign_outcome'))
ALTER TABLE cid.cid_ci_campaign_outcome
  ADD CONSTRAINT FK_cid_ci_camp_out_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_camp_out_outcome' AND parent_object_id = OBJECT_ID('cid.cid_ci_campaign_outcome'))
ALTER TABLE cid.cid_ci_campaign_outcome
  ADD CONSTRAINT FK_cid_ci_camp_out_outcome FOREIGN KEY (outcome_code) REFERENCES cid.cid_ci_ref_outcome(outcome_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_lead_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_lead'))
ALTER TABLE cid.cid_ci_lead
  ADD CONSTRAINT FK_cid_ci_lead_entity FOREIGN KEY (prospect_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_lead_campaign' AND parent_object_id = OBJECT_ID('cid.cid_ci_lead'))
ALTER TABLE cid.cid_ci_lead
  ADD CONSTRAINT FK_cid_ci_lead_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_lead_owner' AND parent_object_id = OBJECT_ID('cid.cid_ci_lead'))
ALTER TABLE cid.cid_ci_lead
  ADD CONSTRAINT FK_cid_ci_lead_owner FOREIGN KEY (owner_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_lead_source' AND parent_object_id = OBJECT_ID('cid.cid_ci_lead'))
ALTER TABLE cid.cid_ci_lead
  ADD CONSTRAINT FK_cid_ci_lead_source FOREIGN KEY (source_code) REFERENCES cid.cid_ci_ref_source(source_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_opp_lead' AND parent_object_id = OBJECT_ID('cid.cid_ci_opportunity'))
ALTER TABLE cid.cid_ci_opportunity
  ADD CONSTRAINT FK_cid_ci_opp_lead FOREIGN KEY (lead_id) REFERENCES cid.cid_ci_lead(lead_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_opp_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_opportunity'))
ALTER TABLE cid.cid_ci_opportunity
  ADD CONSTRAINT FK_cid_ci_opp_entity FOREIGN KEY (prospect_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_opp_stage' AND parent_object_id = OBJECT_ID('cid.cid_ci_opportunity'))
ALTER TABLE cid.cid_ci_opportunity
  ADD CONSTRAINT FK_cid_ci_opp_stage FOREIGN KEY (stage_code) REFERENCES cid.cid_ci_journey_stage(stage_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_opp_owner' AND parent_object_id = OBJECT_ID('cid.cid_ci_opportunity'))
ALTER TABLE cid.cid_ci_opportunity
  ADD CONSTRAINT FK_cid_ci_opp_owner FOREIGN KEY (owner_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_opp_source' AND parent_object_id = OBJECT_ID('cid.cid_ci_opportunity'))
ALTER TABLE cid.cid_ci_opportunity
  ADD CONSTRAINT FK_cid_ci_opp_source FOREIGN KEY (source_code) REFERENCES cid.cid_ci_ref_source(source_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_opp_lost_reason' AND parent_object_id = OBJECT_ID('cid.cid_ci_opportunity'))
ALTER TABLE cid.cid_ci_opportunity
  ADD CONSTRAINT FK_cid_ci_opp_lost_reason FOREIGN KEY (lost_reason_code) REFERENCES cid.cid_ci_ref_lost_reason(lost_reason_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_signal_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_signal'))
ALTER TABLE cid.cid_ci_signal
  ADD CONSTRAINT FK_cid_ci_signal_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_signal_event' AND parent_object_id = OBJECT_ID('cid.cid_ci_signal'))
ALTER TABLE cid.cid_ci_signal
  ADD CONSTRAINT FK_cid_ci_signal_event FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_interaction_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_interaction'))
ALTER TABLE cid.cid_ci_interaction
  ADD CONSTRAINT FK_cid_ci_interaction_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_interaction_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_interaction'))
ALTER TABLE cid.cid_ci_interaction
  ADD CONSTRAINT FK_cid_ci_interaction_type FOREIGN KEY (interaction_type_code) REFERENCES cid.cid_ci_ref_interaction_type(interaction_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_interaction_actor' AND parent_object_id = OBJECT_ID('cid.cid_ci_interaction'))
ALTER TABLE cid.cid_ci_interaction
  ADD CONSTRAINT FK_cid_ci_interaction_actor FOREIGN KEY (actor_entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_interaction_direction' AND parent_object_id = OBJECT_ID('cid.cid_ci_interaction'))
ALTER TABLE cid.cid_ci_interaction
  ADD CONSTRAINT FK_cid_ci_interaction_direction FOREIGN KEY (direction_code) REFERENCES cid.cid_ci_ref_direction(direction_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_interaction_medium' AND parent_object_id = OBJECT_ID('cid.cid_ci_interaction'))
ALTER TABLE cid.cid_ci_interaction
  ADD CONSTRAINT FK_cid_ci_interaction_medium FOREIGN KEY (medium_code) REFERENCES cid.cid_ci_ref_medium(medium_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_interaction_outcome' AND parent_object_id = OBJECT_ID('cid.cid_ci_interaction'))
ALTER TABLE cid.cid_ci_interaction
  ADD CONSTRAINT FK_cid_ci_interaction_outcome FOREIGN KEY (outcome_code) REFERENCES cid.cid_ci_ref_outcome(outcome_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_interaction_policy' AND parent_object_id = OBJECT_ID('cid.cid_ci_interaction'))
ALTER TABLE cid.cid_ci_interaction
  ADD CONSTRAINT FK_cid_ci_interaction_policy FOREIGN KEY (policy_id) REFERENCES core.policy(policy_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_interaction_channel' AND parent_object_id = OBJECT_ID('cid.cid_ci_interaction'))
ALTER TABLE cid.cid_ci_interaction
  ADD CONSTRAINT FK_cid_ci_interaction_channel FOREIGN KEY (channel_id) REFERENCES cid.cid_ch_channel(channel_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_interaction_campaign' AND parent_object_id = OBJECT_ID('cid.cid_ci_interaction'))
ALTER TABLE cid.cid_ci_interaction
  ADD CONSTRAINT FK_cid_ci_interaction_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ci_evt_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_event'))
ALTER TABLE cid.cid_ci_event
  ADD CONSTRAINT FK_ci_evt_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ci_evt_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_event'))
ALTER TABLE cid.cid_ci_event
  ADD CONSTRAINT FK_ci_evt_type FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ci_evt_campaign' AND parent_object_id = OBJECT_ID('cid.cid_ci_event'))
ALTER TABLE cid.cid_ci_event
  ADD CONSTRAINT FK_ci_evt_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ci_evt_interact' AND parent_object_id = OBJECT_ID('cid.cid_ci_event'))
ALTER TABLE cid.cid_ci_event
  ADD CONSTRAINT FK_ci_evt_interact FOREIGN KEY (interaction_id) REFERENCES cid.cid_ci_interaction(interaction_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ci_evt_lead' AND parent_object_id = OBJECT_ID('cid.cid_ci_event'))
ALTER TABLE cid.cid_ci_event
  ADD CONSTRAINT FK_ci_evt_lead FOREIGN KEY (lead_id) REFERENCES cid.cid_ci_lead(lead_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ci_evt_opp' AND parent_object_id = OBJECT_ID('cid.cid_ci_event'))
ALTER TABLE cid.cid_ci_event
  ADD CONSTRAINT FK_ci_evt_opp FOREIGN KEY (opportunity_id) REFERENCES cid.cid_ci_opportunity(opportunity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ci_evt_policy' AND parent_object_id = OBJECT_ID('cid.cid_ci_event'))
ALTER TABLE cid.cid_ci_event
  ADD CONSTRAINT FK_ci_evt_policy FOREIGN KEY (policy_id) REFERENCES core.policy(policy_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ci_evt_channel' AND parent_object_id = OBJECT_ID('cid.cid_ci_event'))
ALTER TABLE cid.cid_ci_event
  ADD CONSTRAINT FK_ci_evt_channel FOREIGN KEY (channel_id) REFERENCES cid.cid_ch_channel(channel_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_aud_mem_aud' AND parent_object_id = OBJECT_ID('cid.cid_ci_audience_member'))
ALTER TABLE cid.cid_ci_audience_member
  ADD CONSTRAINT FK_cid_ci_aud_mem_aud FOREIGN KEY (audience_id) REFERENCES cid.cid_ci_audience_definition(audience_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_aud_mem_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_audience_member'))
ALTER TABLE cid.cid_ci_audience_member
  ADD CONSTRAINT FK_cid_ci_aud_mem_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_survey_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_survey'))
ALTER TABLE cid.cid_ci_survey
  ADD CONSTRAINT FK_cid_ci_survey_type FOREIGN KEY (survey_type_code) REFERENCES cid.cid_ci_ref_survey_type(survey_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_sresp_survey' AND parent_object_id = OBJECT_ID('cid.cid_ci_survey_response'))
ALTER TABLE cid.cid_ci_survey_response
  ADD CONSTRAINT FK_cid_ci_sresp_survey FOREIGN KEY (survey_id) REFERENCES cid.cid_ci_survey(survey_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_sresp_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_survey_response'))
ALTER TABLE cid.cid_ci_survey_response
  ADD CONSTRAINT FK_cid_ci_sresp_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_sim_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_simulation'))
ALTER TABLE cid.cid_ci_event_simulation
  ADD CONSTRAINT FK_cid_ci_evt_sim_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_sim_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_simulation'))
ALTER TABLE cid.cid_ci_event_simulation
  ADD CONSTRAINT FK_cid_ci_evt_sim_type FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_conv_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_conversion'))
ALTER TABLE cid.cid_ci_event_conversion
  ADD CONSTRAINT FK_cid_ci_evt_conv_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_conv_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_conversion'))
ALTER TABLE cid.cid_ci_event_conversion
  ADD CONSTRAINT FK_cid_ci_evt_conv_type FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_int_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_interaction'))
ALTER TABLE cid.cid_ci_event_interaction
  ADD CONSTRAINT FK_cid_ci_evt_int_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_int_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_interaction'))
ALTER TABLE cid.cid_ci_event_interaction
  ADD CONSTRAINT FK_cid_ci_evt_int_type FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_int_interaction' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_interaction'))
ALTER TABLE cid.cid_ci_event_interaction
  ADD CONSTRAINT FK_cid_ci_evt_int_interaction FOREIGN KEY (interaction_id) REFERENCES cid.cid_ci_interaction(interaction_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_exp_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_campaign_exposure'))
ALTER TABLE cid.cid_ci_event_campaign_exposure
  ADD CONSTRAINT FK_cid_ci_evt_exp_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_exp_campaign' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_campaign_exposure'))
ALTER TABLE cid.cid_ci_event_campaign_exposure
  ADD CONSTRAINT FK_cid_ci_evt_exp_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_exp_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_campaign_exposure'))
ALTER TABLE cid.cid_ci_event_campaign_exposure
  ADD CONSTRAINT FK_cid_ci_evt_exp_type FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_resp_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_campaign_response'))
ALTER TABLE cid.cid_ci_event_campaign_response
  ADD CONSTRAINT FK_cid_ci_evt_resp_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_resp_campaign' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_campaign_response'))
ALTER TABLE cid.cid_ci_event_campaign_response
  ADD CONSTRAINT FK_cid_ci_evt_resp_campaign FOREIGN KEY (campaign_id) REFERENCES cid.cid_ci_campaign(campaign_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_resp_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_campaign_response'))
ALTER TABLE cid.cid_ci_event_campaign_response
  ADD CONSTRAINT FK_cid_ci_evt_resp_type FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_xsell_entity' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_cross_sell_trigger'))
ALTER TABLE cid.cid_ci_event_cross_sell_trigger
  ADD CONSTRAINT FK_cid_ci_evt_xsell_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_ci_evt_xsell_type' AND parent_object_id = OBJECT_ID('cid.cid_ci_event_cross_sell_trigger'))
ALTER TABLE cid.cid_ci_event_cross_sell_trigger
  ADD CONSTRAINT FK_cid_ci_evt_xsell_type FOREIGN KEY (event_type_code) REFERENCES cid.cid_ci_ref_event_type(event_type_code);
GO

-- Relationships from 05_Conduct.sql
IF OBJECT_ID('cid.cid_cond_complaint','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_complaint_entity' AND parent_object_id = OBJECT_ID('cid.cid_cond_complaint'))
ALTER TABLE cid.cid_cond_complaint
  ADD CONSTRAINT FK_cid_cond_complaint_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF OBJECT_ID('cid.cid_cond_complaint','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_complaint_policy' AND parent_object_id = OBJECT_ID('cid.cid_cond_complaint'))
ALTER TABLE cid.cid_cond_complaint
  ADD CONSTRAINT FK_cid_cond_complaint_policy FOREIGN KEY (policy_id) REFERENCES core.policy(policy_id);
GO

IF OBJECT_ID('cid.cid_cond_complaint','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_complaint_channel' AND parent_object_id = OBJECT_ID('cid.cid_cond_complaint'))
ALTER TABLE cid.cid_cond_complaint
  ADD CONSTRAINT FK_cid_cond_complaint_channel FOREIGN KEY (channel_id) REFERENCES cid.cid_ch_channel(channel_id);
GO

IF OBJECT_ID('cid.cid_cond_suitability','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_suit_entity' AND parent_object_id = OBJECT_ID('cid.cid_cond_suitability'))
ALTER TABLE cid.cid_cond_suitability
  ADD CONSTRAINT FK_cid_cond_suit_entity FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

IF OBJECT_ID('cid.cid_cond_suitability','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_suit_intermediary' AND parent_object_id = OBJECT_ID('cid.cid_cond_suitability'))
ALTER TABLE cid.cid_cond_suitability
  ADD CONSTRAINT FK_cid_cond_suit_intermediary FOREIGN KEY (intermediary_id) REFERENCES cid.cid_int_intermediary(intermediary_id);
GO

IF OBJECT_ID('cid.cid_cond_suitability','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_suit_policy' AND parent_object_id = OBJECT_ID('cid.cid_cond_suitability'))
ALTER TABLE cid.cid_cond_suitability
  ADD CONSTRAINT FK_cid_cond_suit_policy FOREIGN KEY (policy_id) REFERENCES core.policy(policy_id);
GO

IF OBJECT_ID('cid.cid_cond_product_governance','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_pog_product' AND parent_object_id = OBJECT_ID('cid.cid_cond_product_governance'))
ALTER TABLE cid.cid_cond_product_governance
  ADD CONSTRAINT FK_cid_cond_pog_product FOREIGN KEY (product_family_code) REFERENCES core.ref_product_family(product_family_code);
GO

IF OBJECT_ID('cid.cid_cond_product_governance','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_pog_policy' AND parent_object_id = OBJECT_ID('cid.cid_cond_product_governance'))
ALTER TABLE cid.cid_cond_product_governance
  ADD CONSTRAINT FK_cid_cond_pog_policy FOREIGN KEY (policy_id) REFERENCES core.policy(policy_id);
GO

-- Relationships from Pricing.sql
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_curve_currency' AND parent_object_id = OBJECT_ID('rar.rar_prc_curve_ref'))
ALTER TABLE rar.rar_prc_curve_ref
  ADD CONSTRAINT FK_rar_curve_currency FOREIGN KEY (currency_code) REFERENCES ss.data_ref_currency(currency_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_cp_curve' AND parent_object_id = OBJECT_ID('rar.rar_prc_curve_point'))
ALTER TABLE rar.rar_prc_curve_point
  ADD CONSTRAINT FK_rar_cp_curve FOREIGN KEY (curve_id) REFERENCES rar.rar_prc_curve_ref(curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_run_currency' AND parent_object_id = OBJECT_ID('rar.rar_prc__run'))
ALTER TABLE rar.rar_prc__run
  ADD CONSTRAINT FK_rar_run_currency FOREIGN KEY (currency_code) REFERENCES ss.data_ref_currency(currency_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_run_model' AND parent_object_id = OBJECT_ID('rar.rar_prc__run'))
ALTER TABLE rar.rar_prc__run
  ADD CONSTRAINT FK_rar_run_model FOREIGN KEY (model_registry_id) REFERENCES rar.rar_prc_model_registry(model_registry_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_run_input' AND parent_object_id = OBJECT_ID('rar.rar_prc__run'))
ALTER TABLE rar.rar_prc__run
  ADD CONSTRAINT FK_rar_run_input FOREIGN KEY (input_snapshot_id) REFERENCES rar.rar_prc_input_snapshot(input_snapshot_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_run_calib' AND parent_object_id = OBJECT_ID('rar.rar_prc__run'))
ALTER TABLE rar.rar_prc__run
  ADD CONSTRAINT FK_rar_run_calib FOREIGN KEY (calib_set_id) REFERENCES rar.rar_prc_calibration_set_ref(calib_set_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_run_curve' AND parent_object_id = OBJECT_ID('rar.rar_prc__run'))
ALTER TABLE rar.rar_prc__run
  ADD CONSTRAINT FK_rar_run_curve FOREIGN KEY (curve_id) REFERENCES rar.rar_prc_curve_ref(curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_out_currency' AND parent_object_id = OBJECT_ID('rar.rar_prc_output'))
ALTER TABLE rar.rar_prc_output
  ADD CONSTRAINT FK_rar_out_currency FOREIGN KEY (currency_code) REFERENCES ss.data_ref_currency(currency_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_out_run' AND parent_object_id = OBJECT_ID('rar.rar_prc_output'))
ALTER TABLE rar.rar_prc_output
  ADD CONSTRAINT FK_rar_out_run FOREIGN KEY (run_id) REFERENCES rar.rar_prc__run(run_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_exp_run' AND parent_object_id = OBJECT_ID('rar.rar_prc_explainability'))
ALTER TABLE rar.rar_prc_explainability
  ADD CONSTRAINT FK_rar_exp_run FOREIGN KEY (run_id) REFERENCES rar.rar_prc__run(run_id);
GO
