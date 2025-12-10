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

IF COL_LENGTH('core.ref_lob', 'lob_code') IS NOT NULL
AND (
  SELECT CASE WHEN t.name = 'nvarchar' AND c.max_length = 20 THEN 1 ELSE 0 END
  FROM sys.columns c
  JOIN sys.types t ON c.user_type_id = t.user_type_id
  WHERE c.object_id = OBJECT_ID('core.ref_lob') AND c.name = 'lob_code'
) = 0
  ALTER TABLE core.ref_lob ALTER COLUMN lob_code NVARCHAR(10) NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_policy_lob' AND parent_object_id = OBJECT_ID('core.core_policy'))
ALTER TABLE core.core_policy
  ADD CONSTRAINT FK_policy_lob FOREIGN KEY (lob_code) REFERENCES core.ref_lob(lob_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ppr_policy' AND parent_object_id = OBJECT_ID('core.entity_policy_role'))
ALTER TABLE core.entity_policy_role
  ADD CONSTRAINT FK_ppr_policy FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
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
  ADD CONSTRAINT FK_per_policy FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
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
  ADD CONSTRAINT FK_cid_ci_interaction_policy FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
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
  ADD CONSTRAINT FK_ci_evt_policy FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
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
  ADD CONSTRAINT FK_cid_cond_complaint_policy FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
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
  ADD CONSTRAINT FK_cid_cond_suit_policy FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
GO

IF OBJECT_ID('cid.cid_cond_product_governance','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_pog_product' AND parent_object_id = OBJECT_ID('cid.cid_cond_product_governance'))
ALTER TABLE cid.cid_cond_product_governance
  ADD CONSTRAINT FK_cid_cond_pog_product FOREIGN KEY (product_family_code) REFERENCES core.ref_product_family(product_family_code);
GO

IF OBJECT_ID('cid.cid_cond_product_governance','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_cid_cond_pog_policy' AND parent_object_id = OBJECT_ID('cid.cid_cond_product_governance'))
ALTER TABLE cid.cid_cond_product_governance
  ADD CONSTRAINT FK_cid_cond_pog_policy FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
GO

-- Relationships from Pricing.sql
IF OBJECT_ID('ss.data_ref_currency','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_curve_currency' AND parent_object_id = OBJECT_ID('rar.rar_prc_curve_ref'))
ALTER TABLE rar.rar_prc_curve_ref
  ADD CONSTRAINT FK_rar_curve_currency FOREIGN KEY (currency_code) REFERENCES ss.data_ref_currency(currency_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_cp_curve' AND parent_object_id = OBJECT_ID('rar.rar_prc_curve_point'))
ALTER TABLE rar.rar_prc_curve_point
  ADD CONSTRAINT FK_rar_cp_curve FOREIGN KEY (curve_id) REFERENCES rar.rar_prc_curve_ref(curve_id);
GO

IF OBJECT_ID('ss.data_ref_currency','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_run_currency' AND parent_object_id = OBJECT_ID('rar.rar_prc__run'))
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

IF OBJECT_ID('ss.data_ref_currency','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_out_currency' AND parent_object_id = OBJECT_ID('rar.rar_prc_output'))
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

/* ============================================================
   RAR → RISK (Part 2) — Wiring (UNIQUEs, FKs, Indexes)
   - Idempotent (checks by name/object_id)
   - Intra-RAR; clean FK to Pricing model version (if exists)
   ============================================================ */

/* UNIQUEs moved out of Part 1 */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'UX_rar_risk_factor_code'
    AND object_id = OBJECT_ID('rar.rar_risk_factor_ref')
)
ALTER TABLE rar.rar_risk_factor_ref
  ADD CONSTRAINT UX_rar_risk_factor_code UNIQUE (factor_code);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'UX_rar_risk_event_key'
    AND object_id = OBJECT_ID('rar.rar_risk_event_ref')
)
ALTER TABLE rar.rar_risk_event_ref
  ADD CONSTRAINT UX_rar_risk_event_key UNIQUE (event_key);
GO

/* Natural uniqueness for risk_object */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'UX_rar_ro_subject'
    AND object_id = OBJECT_ID('rar.rar_risk_object')
)
CREATE UNIQUE INDEX UX_rar_ro_subject
  ON rar.rar_risk_object(subject_type, subject_key);
GO

/* Exposure: FKs & indexes */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_rex_snapshot' AND parent_object_id = OBJECT_ID('rar.rar_risk_exposure'))
ALTER TABLE rar.rar_risk_exposure
  ADD CONSTRAINT FK_rar_rex_snapshot
  FOREIGN KEY (exposure_snapshot_id)
  REFERENCES rar.rar_risk_exposure_snapshot(exposure_snapshot_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_rex_object' AND parent_object_id = OBJECT_ID('rar.rar_risk_exposure'))
ALTER TABLE rar.rar_risk_exposure
  ADD CONSTRAINT FK_rar_rex_object
  FOREIGN KEY (risk_object_id)
  REFERENCES rar.rar_risk_object(risk_object_id);
GO

/* Optional when vocabulary stabilizes
-- IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_rex_peril' AND parent_object_id = OBJECT_ID('rar.rar_risk_exposure'))
-- ALTER TABLE rar.rar_risk_exposure
--   ADD CONSTRAINT FK_rar_rex_peril FOREIGN KEY (peril_code)
--   REFERENCES rar.rar_risk_peril_ref(peril_code);
-- GO
*/

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_rar_rex_snapshot'
    AND object_id = OBJECT_ID('rar.rar_risk_exposure')
)
CREATE INDEX IX_rar_rex_snapshot
  ON rar.rar_risk_exposure(exposure_snapshot_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_rar_rex_object'
    AND object_id = OBJECT_ID('rar.rar_risk_exposure')
)
CREATE INDEX IX_rar_rex_object
  ON rar.rar_risk_exposure(risk_object_id)
  INCLUDE (peril_code, sum_insured_amount, sum_insured_currency, geohash, cell_key);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_rar_rex_peril'
    AND object_id = OBJECT_ID('rar.rar_risk_exposure')
)
CREATE INDEX IX_rar_rex_peril
  ON rar.rar_risk_exposure(peril_code);
GO

/* Assessment: FKs & indexes */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_ras_object' AND parent_object_id = OBJECT_ID('rar.rar_risk_assessment'))
ALTER TABLE rar.rar_risk_assessment
  ADD CONSTRAINT FK_rar_ras_object
  FOREIGN KEY (risk_object_id)
  REFERENCES rar.rar_risk_object(risk_object_id);
GO

/* Clean FK to Pricing model version (no floating target) */
IF OBJECT_ID('rar.rar_prc_model_version','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_ras_model_version' AND parent_object_id = OBJECT_ID('rar.rar_risk_assessment'))
ALTER TABLE rar.rar_risk_assessment
  ADD CONSTRAINT FK_rar_ras_model_version
  FOREIGN KEY (model_version_id)
  REFERENCES rar.rar_prc_model_version(model_version_id);
GO

/* Optional when peril vocab stabilizes
-- IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_ras_peril' AND parent_object_id = OBJECT_ID('rar.rar_risk_assessment'))
-- ALTER TABLE rar.rar_risk_assessment
--   ADD CONSTRAINT FK_rar_ras_peril FOREIGN KEY (peril_code)
--   REFERENCES rar.rar_risk_peril_ref(peril_code);
-- GO
*/

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_rar_ras_obj_peril_ts'
    AND object_id = OBJECT_ID('rar.rar_risk_assessment')
)
CREATE INDEX IX_rar_ras_obj_peril_ts
  ON rar.rar_risk_assessment(risk_object_id, peril_code, assessed_at);
GO

/* Detail→header join */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_rar_raf_assess'
    AND object_id = OBJECT_ID('rar.rar_risk_assessment_factor')
)
CREATE INDEX IX_rar_raf_assess
  ON rar.rar_risk_assessment_factor(assessment_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_raf_assess' AND parent_object_id = OBJECT_ID('rar.rar_risk_assessment_factor'))
ALTER TABLE rar.rar_risk_assessment_factor
  ADD CONSTRAINT FK_rar_raf_assess
  FOREIGN KEY (assessment_id)
  REFERENCES rar.rar_risk_assessment(assessment_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_raf_factor' AND parent_object_id = OBJECT_ID('rar.rar_risk_assessment_factor'))
ALTER TABLE rar.rar_risk_assessment_factor
  ADD CONSTRAINT FK_rar_raf_factor
  FOREIGN KEY (factor_id)
  REFERENCES rar.rar_risk_factor_ref(factor_id);
GO

/* Accumulation: FKs & indexes */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_accu_detail_snapshot' AND parent_object_id = OBJECT_ID('rar.rar_risk_accumulation_detail'))
ALTER TABLE rar.rar_risk_accumulation_detail
  ADD CONSTRAINT FK_rar_accu_detail_snapshot
  FOREIGN KEY (accu_snapshot_id)
  REFERENCES rar.rar_risk_accumulation_snapshot(accu_snapshot_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_rar_accu_snapshot'
    AND object_id = OBJECT_ID('rar.rar_risk_accumulation_detail')
)
CREATE INDEX IX_rar_accu_snapshot
  ON rar.rar_risk_accumulation_detail(accu_snapshot_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_rar_accu_cell_peril'
    AND object_id = OBJECT_ID('rar.rar_risk_accumulation_detail')
)
CREATE INDEX IX_rar_accu_cell_peril
  ON rar.rar_risk_accumulation_detail(cell_key, peril_code);
GO

/* Events: FKs & indexes */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_evimp_event' AND parent_object_id = OBJECT_ID('rar.rar_risk_event_impact'))
ALTER TABLE rar.rar_risk_event_impact
  ADD CONSTRAINT FK_rar_evimp_event
  FOREIGN KEY (event_id)
  REFERENCES rar.rar_risk_event_ref(event_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_rar_evimp_object' AND parent_object_id = OBJECT_ID('rar.rar_risk_event_impact'))
ALTER TABLE rar.rar_risk_event_impact
  ADD CONSTRAINT FK_rar_evimp_object
  FOREIGN KEY (risk_object_id)
  REFERENCES rar.rar_risk_object(risk_object_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_rar_eventimpact_event'
    AND object_id = OBJECT_ID('rar.rar_risk_event_impact')
)
CREATE INDEX IX_rar_eventimpact_event
  ON rar.rar_risk_event_impact(event_id);
GO

/* ============================================================
   RAR → Reinsurance — PART 2 (Wiring)
   Adds: UNIQUEs, filtered uniques, FKs (intra-RAR only),
         JSON/date/percent/amount checks, and structural indexes.
   Idempotent: checks use object_id / key_constraints
   Requires: Part 1 already created
   ============================================================ */

IF OBJECT_ID('rar.rar_ri_treaty','U') IS NULL
  RETURN;
GO

/* ---------- Natural UNIQUEs ---------- */
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UX_ri_treaty_prog_code')
ALTER TABLE rar.rar_ri_treaty
  ADD CONSTRAINT UX_ri_treaty_prog_code UNIQUE(program_year_id, treaty_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UX_ri_tver_ver')
ALTER TABLE rar.rar_ri_treaty_version
  ADD CONSTRAINT UX_ri_tver_ver UNIQUE(treaty_id, version_tag);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UX_ri_layer_ord')
ALTER TABLE rar.rar_ri_treaty_layer
  ADD CONSTRAINT UX_ri_layer_ord UNIQUE(treaty_version_id, layer_no);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UX_ri_participant_code')
ALTER TABLE rar.rar_ri_market_participant
  ADD CONSTRAINT UX_ri_participant_code UNIQUE(participant_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UX_ri_period_key')
ALTER TABLE rar.rar_ri_accounting_period
  ADD CONSTRAINT UX_ri_period_key UNIQUE(period_key);
GO

/* ---------- Placements: filtered uniques (version-level vs per-layer) ---------- */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'UX_ri_place_ver_part_nolayer'
    AND object_id = OBJECT_ID('rar.rar_ri_placement_share')
)
CREATE UNIQUE INDEX UX_ri_place_ver_part_nolayer
  ON rar.rar_ri_placement_share(treaty_version_id, participant_id)
  WHERE layer_id IS NULL;
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'UX_ri_place_layer_part'
    AND object_id = OBJECT_ID('rar.rar_ri_placement_share')
)
CREATE UNIQUE INDEX UX_ri_place_layer_part
  ON rar.rar_ri_placement_share(layer_id, participant_id)
  WHERE layer_id IS NOT NULL;
GO

/* ---------- JSON / Date / Percent / Amount Checks ---------- */
/* Dates */
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_prog_dates')
ALTER TABLE rar.rar_ri_program_year
  ADD CONSTRAINT CK_ri_prog_dates CHECK (end_date IS NULL OR end_date >= start_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_treaty_dates')
ALTER TABLE rar.rar_ri_treaty
  ADD CONSTRAINT CK_ri_treaty_dates CHECK (expiry_date IS NULL OR expiry_date >= inception_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_tver_dates')
ALTER TABLE rar.rar_ri_treaty_version
  ADD CONSTRAINT CK_ri_tver_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_ap_dates')
ALTER TABLE rar.rar_ri_accounting_period
  ADD CONSTRAINT CK_ri_ap_dates CHECK (end_date >= start_date);
GO

/* Percent 0..1 */
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_place_pct')
ALTER TABLE rar.rar_ri_placement_share
  ADD CONSTRAINT CK_ri_place_pct CHECK (
    share_pct BETWEEN 0 AND 1 AND
    (brokerage_pct IS NULL OR brokerage_pct BETWEEN 0 AND 1)
  );
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_cess_rate')
ALTER TABLE rar.rar_ri_cession
  ADD CONSTRAINT CK_ri_cess_rate CHECK (ceded_rate_pct BETWEEN 0 AND 1);
GO

/* JSON sanity */
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_layer_term_json')
ALTER TABLE rar.rar_ri_treaty_layer_term
  ADD CONSTRAINT CK_ri_layer_term_json CHECK (term_value_json IS NULL OR ISJSON(term_value_json) = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_layerterm_any')
ALTER TABLE rar.rar_ri_treaty_layer_term
  ADD CONSTRAINT CK_ri_layerterm_any CHECK (
    term_value_txt IS NOT NULL OR term_value_num IS NOT NULL OR term_value_json IS NOT NULL
  );
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_decl_meta')
ALTER TABLE rar.rar_ri_declaration
  ADD CONSTRAINT CK_ri_decl_meta CHECK (metadata_json IS NULL OR ISJSON(metadata_json) = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_settle_json')
ALTER TABLE rar.rar_ri_settlement_statement
  ADD CONSTRAINT CK_ri_settle_json CHECK (statement_json IS NULL OR ISJSON(statement_json) = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_exprun_params')
ALTER TABLE rar.rar_ri_expected_recovery_run
  ADD CONSTRAINT CK_ri_exprun_params CHECK (params_json IS NULL OR ISJSON(params_json) = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_exppc_meta')
ALTER TABLE rar.rar_ri_exposure_pc
  ADD CONSTRAINT CK_ri_exppc_meta CHECK (metadata_json IS NULL OR ISJSON(metadata_json) = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_explife_meta')
ALTER TABLE rar.rar_ri_exposure_life
  ADD CONSTRAINT CK_ri_explife_meta CHECK (metadata_json IS NULL OR ISJSON(metadata_json) = 1);
GO

/* Layer amounts non-negative */
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_ri_layer_amt_basic')
ALTER TABLE rar.rar_ri_treaty_layer
  ADD CONSTRAINT CK_ri_layer_amt_basic CHECK (
    (limit_amount IS NULL OR limit_amount >= 0) AND
    (attachment_amount IS NULL OR attachment_amount >= 0) AND
    (aggregate_limit_amount IS NULL OR aggregate_limit_amount >= 0) AND
    (deductible_amount IS NULL OR deductible_amount >= 0)
  );
GO

/* ---------- Foreign Keys (intra-RAR only) ---------- */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_treaty_prog')
ALTER TABLE rar.rar_ri_treaty
  ADD CONSTRAINT FK_ri_treaty_prog
  FOREIGN KEY (program_year_id) REFERENCES rar.rar_ri_program_year(program_year_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_tver_treaty')
ALTER TABLE rar.rar_ri_treaty_version
  ADD CONSTRAINT FK_ri_tver_treaty
  FOREIGN KEY (treaty_id) REFERENCES rar.rar_ri_treaty(treaty_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_layer_tver')
ALTER TABLE rar.rar_ri_treaty_layer
  ADD CONSTRAINT FK_ri_layer_tver
  FOREIGN KEY (treaty_version_id) REFERENCES rar.rar_ri_treaty_version(treaty_version_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_lterm_layer')
ALTER TABLE rar.rar_ri_treaty_layer_term
  ADD CONSTRAINT FK_ri_lterm_layer
  FOREIGN KEY (layer_id) REFERENCES rar.rar_ri_treaty_layer(layer_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_place_tver')
ALTER TABLE rar.rar_ri_placement_share
  ADD CONSTRAINT FK_ri_place_tver
  FOREIGN KEY (treaty_version_id) REFERENCES rar.rar_ri_treaty_version(treaty_version_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_place_layer')
ALTER TABLE rar.rar_ri_placement_share
  ADD CONSTRAINT FK_ri_place_layer
  FOREIGN KEY (layer_id) REFERENCES rar.rar_ri_treaty_layer(layer_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_place_part')
ALTER TABLE rar.rar_ri_placement_share
  ADD CONSTRAINT FK_ri_place_part
  FOREIGN KEY (participant_id) REFERENCES rar.rar_ri_market_participant(participant_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_decl_tver')
ALTER TABLE rar.rar_ri_declaration
  ADD CONSTRAINT FK_ri_decl_tver
  FOREIGN KEY (treaty_version_id) REFERENCES rar.rar_ri_treaty_version(treaty_version_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_decl_ap')
ALTER TABLE rar.rar_ri_declaration
  ADD CONSTRAINT FK_ri_decl_ap
  FOREIGN KEY (accounting_period_id) REFERENCES rar.rar_ri_accounting_period(accounting_period_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_cess_decl')
ALTER TABLE rar.rar_ri_cession
  ADD CONSTRAINT FK_ri_cess_decl
  FOREIGN KEY (declaration_id) REFERENCES rar.rar_ri_declaration(declaration_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_cess_layer')
ALTER TABLE rar.rar_ri_cession
  ADD CONSTRAINT FK_ri_cess_layer
  FOREIGN KEY (layer_id) REFERENCES rar.rar_ri_treaty_layer(layer_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_bdp_decl')
ALTER TABLE rar.rar_ri_bordereau_premium
  ADD CONSTRAINT FK_ri_bdp_decl
  FOREIGN KEY (declaration_id) REFERENCES rar.rar_ri_declaration(declaration_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_bdp_ap')
ALTER TABLE rar.rar_ri_bordereau_premium
  ADD CONSTRAINT FK_ri_bdp_ap
  FOREIGN KEY (accounting_period_id) REFERENCES rar.rar_ri_accounting_period(accounting_period_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_bdc_decl')
ALTER TABLE rar.rar_ri_bordereau_claims
  ADD CONSTRAINT FK_ri_bdc_decl
  FOREIGN KEY (declaration_id) REFERENCES rar.rar_ri_declaration(declaration_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_bdc_ap')
ALTER TABLE rar.rar_ri_bordereau_claims
  ADD CONSTRAINT FK_ri_bdc_ap
  FOREIGN KEY (accounting_period_id) REFERENCES rar.rar_ri_accounting_period(accounting_period_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_recv_layer')
ALTER TABLE rar.rar_ri_recovery_event
  ADD CONSTRAINT FK_ri_recv_layer
  FOREIGN KEY (layer_id) REFERENCES rar.rar_ri_treaty_layer(layer_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_settle_tver')
ALTER TABLE rar.rar_ri_settlement_statement
  ADD CONSTRAINT FK_ri_settle_tver
  FOREIGN KEY (treaty_version_id) REFERENCES rar.rar_ri_treaty_version(treaty_version_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_settle_ap')
ALTER TABLE rar.rar_ri_settlement_statement
  ADD CONSTRAINT FK_ri_settle_ap
  FOREIGN KEY (accounting_period_id) REFERENCES rar.rar_ri_accounting_period(accounting_period_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_exprun_tver')
ALTER TABLE rar.rar_ri_expected_recovery_run
  ADD CONSTRAINT FK_ri_exprun_tver
  FOREIGN KEY (treaty_version_id) REFERENCES rar.rar_ri_treaty_version(treaty_version_id);
GO

/* Optional FK: treaty layer → reinstatement basis catalog */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ri_layer_reinst')
AND EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('rar.rar_ref_reinstatement_basis') AND type = 'U')
ALTER TABLE rar.rar_ri_treaty_layer
  ADD CONSTRAINT FK_ri_layer_reinst
  FOREIGN KEY (reinstatement_basis_code) REFERENCES rar.rar_ref_reinstatement_basis(reinstatement_basis_code);
GO

/* ---------- Structural Indexes (idempotent with object_id) ---------- */
/* Core navigation: program → treaty → version → layer */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_treaty_prog'
    AND object_id = OBJECT_ID('rar.rar_ri_treaty')
)
CREATE INDEX IX_ri_treaty_prog ON rar.rar_ri_treaty(program_year_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_tver_treaty'
    AND object_id = OBJECT_ID('rar.rar_ri_treaty_version')
)
CREATE INDEX IX_ri_tver_treaty ON rar.rar_ri_treaty_version(treaty_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_layer_tver'
    AND object_id = OBJECT_ID('rar.rar_ri_treaty_layer')
)
CREATE INDEX IX_ri_layer_tver ON rar.rar_ri_treaty_layer(treaty_version_id);
GO

/* Layer terms by layer */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_lterm_layer'
    AND object_id = OBJECT_ID('rar.rar_ri_treaty_layer_term')
)
CREATE INDEX IX_ri_lterm_layer ON rar.rar_ri_treaty_layer_term(layer_id);
GO

/* Placement lookups */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_place_ver'
    AND object_id = OBJECT_ID('rar.rar_ri_placement_share')
)
CREATE INDEX IX_ri_place_ver ON rar.rar_ri_placement_share(treaty_version_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_place_part'
    AND object_id = OBJECT_ID('rar.rar_ri_placement_share')
)
CREATE INDEX IX_ri_place_part ON rar.rar_ri_placement_share(participant_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_place_layer'
    AND object_id = OBJECT_ID('rar.rar_ri_placement_share')
)
CREATE INDEX IX_ri_place_layer ON rar.rar_ri_placement_share(layer_id);
GO

/* Declarations lookups */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_decl_ver_per'
    AND object_id = OBJECT_ID('rar.rar_ri_declaration')
)
CREATE INDEX IX_ri_decl_ver_per ON rar.rar_ri_declaration(treaty_version_id, accounting_period_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_decl_exposure'
    AND object_id = OBJECT_ID('rar.rar_ri_declaration')
)
CREATE INDEX IX_ri_decl_exposure ON rar.rar_ri_declaration(exposure_ref_key);
GO

/* Cessions lookups */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_cess_decl'
    AND object_id = OBJECT_ID('rar.rar_ri_cession')
)
CREATE INDEX IX_ri_cess_decl ON rar.rar_ri_cession(declaration_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_cess_layer'
    AND object_id = OBJECT_ID('rar.rar_ri_cession')
)
CREATE INDEX IX_ri_cess_layer ON rar.rar_ri_cession(layer_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_cess_peril'
    AND object_id = OBJECT_ID('rar.rar_ri_cession')
)
CREATE INDEX IX_ri_cess_peril ON rar.rar_ri_cession(peril_code);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_cess_exposure'
    AND object_id = OBJECT_ID('rar.rar_ri_cession')
)
CREATE INDEX IX_ri_cess_exposure ON rar.rar_ri_cession(exposure_ref_key);
GO

/* Bordereaux lookups */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_bdp_decl_per'
    AND object_id = OBJECT_ID('rar.rar_ri_bordereau_premium')
)
CREATE INDEX IX_ri_bdp_decl_per ON rar.rar_ri_bordereau_premium(declaration_id, accounting_period_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_bdc_decl_per'
    AND object_id = OBJECT_ID('rar.rar_ri_bordereau_claims')
)
CREATE INDEX IX_ri_bdc_decl_per ON rar.rar_ri_bordereau_claims(declaration_id, accounting_period_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_bdc_peril'
    AND object_id = OBJECT_ID('rar.rar_ri_bordereau_claims')
)
CREATE INDEX IX_ri_bdc_peril ON rar.rar_ri_bordereau_claims(peril_code);
GO

/* Recovery & settlements */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_recv_layer'
    AND object_id = OBJECT_ID('rar.rar_ri_recovery_event')
)
CREATE INDEX IX_ri_recv_layer ON rar.rar_ri_recovery_event(layer_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_settle_ver_per'
    AND object_id = OBJECT_ID('rar.rar_ri_settlement_statement')
)
CREATE INDEX IX_ri_settle_ver_per ON rar.rar_ri_settlement_statement(treaty_version_id, accounting_period_id);
GO

/* Exposures */
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_exppc_key'
    AND object_id = OBJECT_ID('rar.rar_ri_exposure_pc')
)
CREATE INDEX IX_ri_exppc_key ON rar.rar_ri_exposure_pc(exposure_ref_key);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_exppc_cell'
    AND object_id = OBJECT_ID('rar.rar_ri_exposure_pc')
)
CREATE INDEX IX_ri_exppc_cell ON rar.rar_ri_exposure_pc(cell_key, peril_code);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_ri_explife_key'
    AND object_id = OBJECT_ID('rar.rar_ri_exposure_life')
)
CREATE INDEX IX_ri_explife_key ON rar.rar_ri_exposure_life(exposure_ref_key);
GO

/* ============================================================
   POLICIES — PART 2 (WIRING)
   UNIQUEs, FKs, CKs, IXs, dynamic views, JSON checks, doc_uri bump.
   Idempotent; uses object_id/key_constraints-aware checks.
   ============================================================ */

-- Natural key (usually per LoB)
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_core_policy_lob_number')
ALTER TABLE core.core_policy
  ADD CONSTRAINT UQ_core_policy_lob_number UNIQUE (lob_code, policy_number);
GO

-- Date sanity
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_core_pol_dates')
ALTER TABLE core.core_policy
  ADD CONSTRAINT CK_core_pol_dates CHECK (expiry_date IS NULL OR expiry_date >= inception_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_core_polterm_dates')
ALTER TABLE core.core_policy_term
  ADD CONSTRAINT CK_core_polterm_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

-- FKs
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_core_poldoc_policy')
ALTER TABLE core.core_policy_document_ref
  ADD CONSTRAINT FK_core_poldoc_policy
  FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
GO

-- Composite FK: coverage(policy_id, version_tag) -> policy_term
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_core_polcov_polterm')
ALTER TABLE core.core_policy_coverage
  ADD CONSTRAINT FK_core_polcov_polterm
  FOREIGN KEY (policy_id, version_tag) REFERENCES core.core_policy_term(policy_id, version_tag);
GO

-- 1–1 LoB extensions → core
IF OBJECT_ID('pc.pc_policy_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_pc_polext_core')
ALTER TABLE pc.pc_policy_ext
  ADD CONSTRAINT FK_pc_polext_core FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
GO

IF OBJECT_ID('lp.lp_policy_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_lp_polext_core')
ALTER TABLE lp.lp_policy_ext
  ADD CONSTRAINT FK_lp_polext_core FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
GO

IF OBJECT_ID('hlth.hlth_policy_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_hlth_polext_core')
ALTER TABLE hlth.hlth_policy_ext
  ADD CONSTRAINT FK_hlth_polext_core FOREIGN KEY (policy_id) REFERENCES core.core_policy(policy_id);
GO

-- Useful Indexes
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_core_polcov_pol_ver' AND object_id = OBJECT_ID('core.core_policy_coverage')
)
CREATE INDEX IX_core_polcov_pol_ver ON core.core_policy_coverage(policy_id, version_tag);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_core_poldoc_policy' AND object_id = OBJECT_ID('core.core_policy_document_ref')
)
CREATE INDEX IX_core_poldoc_policy ON core.core_policy_document_ref(policy_id);
GO

-- JSON hygiene on *_ext
IF OBJECT_ID('pc.pc_policy_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_pc_polext_json')
ALTER TABLE pc.pc_policy_ext ADD CONSTRAINT CK_pc_polext_json CHECK (extra_json IS NULL OR ISJSON(extra_json) = 1);
GO

IF OBJECT_ID('lp.lp_policy_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_lp_polext_json')
ALTER TABLE lp.lp_policy_ext ADD CONSTRAINT CK_lp_polext_json CHECK (extra_json IS NULL OR ISJSON(extra_json) = 1);
GO

IF OBJECT_ID('hlth.hlth_policy_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_hlth_polext_json')
ALTER TABLE hlth.hlth_policy_ext ADD CONSTRAINT CK_hlth_polext_json CHECK (extra_json IS NULL OR ISJSON(extra_json) = 1);
GO

-- Safe bump for doc_uri from NVARCHAR(500) (1000 bytes) to 1000 chars if smaller
IF COL_LENGTH('core.core_policy_document_ref', 'doc_uri') IS NOT NULL
   AND (SELECT max_length FROM sys.columns WHERE object_id = OBJECT_ID('core.core_policy_document_ref') AND name = 'doc_uri') < 1000
ALTER TABLE core.core_policy_document_ref ALTER COLUMN doc_uri NVARCHAR(1000) NULL;
GO

/* Dynamic view: core.v_core_policy — only unions LoBs that exist */
IF OBJECT_ID('core.v_core_policy', 'V') IS NULL
BEGIN
  DECLARE @v NVARCHAR(MAX) = N'SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
CREATE VIEW core.v_core_policy AS ';
  DECLARE @u NVARCHAR(MAX) = N'';

  IF OBJECT_ID('pc.pc_policy', 'U') IS NOT NULL
    SET @u += N'UNION ALL SELECT policy_id, policy_number, N''PC'' AS lob_code, status_code, inception_date, expiry_date, currency_code, created_at FROM pc.pc_policy ';
  IF OBJECT_ID('lp.lp_policy', 'U') IS NOT NULL
    SET @u += N'UNION ALL SELECT policy_id, policy_number, N''LP'' AS lob_code, status_code, inception_date, expiry_date, currency_code, created_at FROM lp.lp_policy ';
  IF OBJECT_ID('hlth.hlth_policy', 'U') IS NOT NULL
    SET @u += N'UNION ALL SELECT policy_id, policy_number, N''HLTH'' AS lob_code, status_code, inception_date, expiry_date, currency_code, created_at FROM hlth.hlth_policy ';

  IF LEN(@u) > 0
  BEGIN
    SET @u = STUFF(@u, 1, 9, N''); -- remove first "UNION ALL "
    EXEC(@v + @u + N';');
  END
END
GO

/* ============================================================
   CLAIMS — PART 2 (WIRING)
   UNIQUEs, FKs, CKs, IXs, dynamic views, JSON checks, defaults.
   Idempotent; uses object_id/key_constraints-aware checks.
   ============================================================ */

-- Natural key (usually per LoB)
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_core_claim_lob_number')
ALTER TABLE core.core_claim_header
  ADD CONSTRAINT UQ_core_claim_lob_number UNIQUE (lob_code, claim_number);
GO

-- Dates sanity on party role
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_core_clmpr_dates')
ALTER TABLE core.core_claim_party_role
  ADD CONSTRAINT CK_core_clmpr_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

-- Dates sanity on claim (loss_date <= reported_at when both set)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_core_clm_dates')
ALTER TABLE core.core_claim_header
  ADD CONSTRAINT CK_core_clm_dates CHECK (loss_date IS NULL OR reported_at IS NULL OR reported_at >= loss_date);
GO

-- Non-negative amounts
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_core_amounts_nonneg_mov')
ALTER TABLE core.core_claim_financial_movement
  ADD CONSTRAINT CK_core_amounts_nonneg_mov CHECK (amount >= 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_core_amounts_nonneg_cov')
ALTER TABLE core.core_claim_coverage
  ADD CONSTRAINT CK_core_amounts_nonneg_cov CHECK (
    (incurred_amount IS NULL OR incurred_amount >= 0) AND
    (reserve_amount  IS NULL OR reserve_amount  >= 0) AND
    (paid_amount     IS NULL OR paid_amount     >= 0)
  );
GO

-- Movement type whitelist (light hygiene)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_core_clmmov_type_whitelist')
ALTER TABLE core.core_claim_financial_movement
  ADD CONSTRAINT CK_core_clmmov_type_whitelist
  CHECK (movement_type IN (N'RESERVE_SET', N'RELEASE', N'PAYMENT', N'RECOVERY'));
GO

-- FK: financial movement -> financial head (composite)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_core_clmmov_head')
ALTER TABLE core.core_claim_financial_movement
  ADD CONSTRAINT FK_core_clmmov_head
  FOREIGN KEY (claim_id, head_code)
  REFERENCES core.core_claim_financial_head(claim_id, head_code);
GO

-- FK: docs to claim
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_core_clmdoc_claim')
ALTER TABLE core.core_claim_document_ref
  ADD CONSTRAINT FK_core_clmdoc_claim
  FOREIGN KEY (claim_id) REFERENCES core.core_claim_header(claim_id);
GO

-- FK: party role to claim
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_core_clmpr_claim')
ALTER TABLE core.core_claim_party_role
  ADD CONSTRAINT FK_core_clmpr_claim
  FOREIGN KEY (claim_id) REFERENCES core.core_claim_header(claim_id);
GO

-- FK: coverage to claim
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_core_clmcov_claim')
ALTER TABLE core.core_claim_coverage
  ADD CONSTRAINT FK_core_clmcov_claim
  FOREIGN KEY (claim_id) REFERENCES core.core_claim_header(claim_id);
GO

-- FK: coverage snapshot to claim
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_core_clmcovsnap_claim')
ALTER TABLE core.core_claim_coverage_snapshot
  ADD CONSTRAINT FK_core_clmcovsnap_claim
  FOREIGN KEY (claim_id) REFERENCES core.core_claim_header(claim_id);
GO

-- 1-1 LoB extensions -> core_claim_header
IF OBJECT_ID('pc.pc_claim_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_pc_clmext_core')
ALTER TABLE pc.pc_claim_ext
  ADD CONSTRAINT FK_pc_clmext_core FOREIGN KEY (claim_id) REFERENCES core.core_claim_header(claim_id);
GO

IF OBJECT_ID('lp.lp_claim_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_lp_clmext_core')
ALTER TABLE lp.lp_claim_ext
  ADD CONSTRAINT FK_lp_clmext_core FOREIGN KEY (claim_id) REFERENCES core.core_claim_header(claim_id);
GO

IF OBJECT_ID('hlth.hlth_claim_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_hlth_clmext_core')
ALTER TABLE hlth.hlth_claim_ext
  ADD CONSTRAINT FK_hlth_clmext_core FOREIGN KEY (claim_id) REFERENCES core.core_claim_header(claim_id);
GO

-- JSON hygiene on *_ext and claim coverage snapshot
IF OBJECT_ID('pc.pc_claim_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_pc_clmext_json')
ALTER TABLE pc.pc_claim_ext ADD CONSTRAINT CK_pc_clmext_json CHECK (extra_json IS NULL OR ISJSON(extra_json) = 1);
GO

IF OBJECT_ID('lp.lp_claim_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_lp_clmext_json')
ALTER TABLE lp.lp_claim_ext ADD CONSTRAINT CK_lp_clmext_json CHECK (extra_json IS NULL OR ISJSON(extra_json) = 1);
GO

IF OBJECT_ID('hlth.hlth_claim_ext', 'U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_hlth_clmext_json')
ALTER TABLE hlth.hlth_claim_ext ADD CONSTRAINT CK_hlth_clmext_json CHECK (extra_json IS NULL OR ISJSON(extra_json) = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_core_clmcovsnap_json')
ALTER TABLE core.core_claim_coverage_snapshot
  ADD CONSTRAINT CK_core_clmcovsnap_json CHECK (coverage_json IS NULL OR ISJSON(coverage_json) = 1);
GO

-- Useful Indexes (idempotent + object-scoped)
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_core_clmdec_claim_ts' AND object_id = OBJECT_ID('core.core_claim_decision')
)
CREATE INDEX IX_core_clmdec_claim_ts ON core.core_claim_decision(claim_id, decided_at);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_core_clmdoc_claim' AND object_id = OBJECT_ID('core.core_claim_document_ref')
)
CREATE INDEX IX_core_clmdoc_claim ON core.core_claim_document_ref(claim_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_core_clmpr_claim' AND object_id = OBJECT_ID('core.core_claim_party_role')
)
CREATE INDEX IX_core_clmpr_claim ON core.core_claim_party_role(claim_id);
GO

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = 'IX_core_clmcov_claim' AND object_id = OBJECT_ID('core.core_claim_coverage')
)
CREATE INDEX IX_core_clmcov_claim ON core.core_claim_coverage(claim_id);
GO

-- reported_at default (keep nullable for historical loads; consider NOT NULL later)
IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_core_clm_reported')
ALTER TABLE core.core_claim_header
  ADD CONSTRAINT DF_core_clm_reported DEFAULT SYSUTCDATETIME() FOR reported_at;
GO

-- Safe bump for doc_uri from NVARCHAR(500) (1000 bytes) to 1000 chars if smaller
IF COL_LENGTH('core.core_claim_document_ref', 'doc_uri') IS NOT NULL
   AND (SELECT max_length FROM sys.columns WHERE object_id = OBJECT_ID('core.core_claim_document_ref') AND name = 'doc_uri') < 1000
ALTER TABLE core.core_claim_document_ref ALTER COLUMN doc_uri NVARCHAR(1000) NULL;
GO

/* Dynamic view: core.v_core_claim_header — only unions LoBs that exist */
IF OBJECT_ID('core.v_core_claim_header', 'V') IS NULL
BEGIN
  DECLARE @v NVARCHAR(MAX) = N'SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;
CREATE VIEW core.v_core_claim_header AS ';
  DECLARE @u NVARCHAR(MAX) = N'';

  IF OBJECT_ID('pc.pc_claim', 'U') IS NOT NULL
    SET @u += N'UNION ALL SELECT claim_id, policy_id, claim_number, N''PC'' AS lob_code, status_code, reported_at, loss_date, cause_code, currency_code, created_at FROM pc.pc_claim ';
  IF OBJECT_ID('lp.lp_claim', 'U') IS NOT NULL
    SET @u += N'UNION ALL SELECT claim_id, policy_id, claim_number, N''LP'' AS lob_code, status_code, reported_at, loss_date, cause_code, currency_code, created_at FROM lp.lp_claim ';
  IF OBJECT_ID('hlth.hlth_claim', 'U') IS NOT NULL
    SET @u += N'UNION ALL SELECT claim_id, policy_id, claim_number, N''HLTH'' AS lob_code, status_code, reported_at, loss_date, cause_code, currency_code, created_at FROM hlth.hlth_claim ';

  IF LEN(@u) > 0
  BEGIN
    SET @u = STUFF(@u, 1, 9, N''); -- remove first "UNION ALL "
    EXEC(@v + @u + N';');
  END
END
GO

/* ============================================================
   UNDERWRITING — PART 2 (WIRING)
   All FKs + performant indexes
   ============================================================ */

-------------------------
-- FOREIGN KEYS
-------------------------

-- Events → Case
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_uwevt_case')
ALTER TABLE core.core_uw_case_event
  ADD CONSTRAINT FK_core_uwevt_case
      FOREIGN KEY (uw_case_id) REFERENCES core.core_uw_case(uw_case_id);
GO

-- Rule outcome → Case
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_uwro_case')
ALTER TABLE core.core_uw_rule_outcome
  ADD CONSTRAINT FK_core_uwro_case
      FOREIGN KEY (uw_case_id) REFERENCES core.core_uw_case(uw_case_id);
GO

-- Rule outcome → Rule version
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_uwro_rulev')
ALTER TABLE core.core_uw_rule_outcome
  ADD CONSTRAINT FK_core_uwro_rulev
      FOREIGN KEY (rule_version_id) REFERENCES core.core_uw_rule_version(rule_version_id);
GO

-- Evidence → Case
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_uwevd_case')
ALTER TABLE core.core_uw_evidence
  ADD CONSTRAINT FK_core_uwevd_case
      FOREIGN KEY (uw_case_id) REFERENCES core.core_uw_case(uw_case_id);
GO

-- Decision → Case (1–1)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_uwdec_case')
ALTER TABLE core.core_uw_decision
  ADD CONSTRAINT FK_core_uwdec_case
      FOREIGN KEY (uw_case_id) REFERENCES core.core_uw_case(uw_case_id);
GO

-- Extensions → Case
IF OBJECT_ID('pc.pc_uw_case_ext','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_pc_uwext_case')
ALTER TABLE pc.pc_uw_case_ext
  ADD CONSTRAINT FK_pc_uwext_case
      FOREIGN KEY (uw_case_id) REFERENCES core.core_uw_case(uw_case_id);
GO

IF OBJECT_ID('lp.lp_uw_case_ext','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_uwext_case')
ALTER TABLE lp.lp_uw_case_ext
  ADD CONSTRAINT FK_lp_uwext_case
      FOREIGN KEY (uw_case_id) REFERENCES core.core_uw_case(uw_case_id);
GO

IF OBJECT_ID('hlth.hlth_uw_case_ext','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_uwext_case')
ALTER TABLE hlth.hlth_uw_case_ext
  ADD CONSTRAINT FK_hlth_uwext_case
      FOREIGN KEY (uw_case_id) REFERENCES core.core_uw_case(uw_case_id);
GO

-------------------------
-- INDEXES (practical)
-------------------------

-- Filtering dashboards: lob/state/date
IF NOT EXISTS (
 SELECT 1 FROM sys.indexes
 WHERE name='IX_core_uwcase_lob_state_created'
   AND object_id=OBJECT_ID('core.core_uw_case')
)
CREATE INDEX IX_core_uwcase_lob_state_created
 ON core.core_uw_case(lob_code, state_code, created_at);
GO

-- Channel filtering
IF NOT EXISTS (
 SELECT 1 FROM sys.indexes
 WHERE name='IX_core_uwcase_channel'
   AND object_id=OBJECT_ID('core.core_uw_case')
)
CREATE INDEX IX_core_uwcase_channel
 ON core.core_uw_case(channel_code);
GO

-- Lookups (proposer/product)
IF NOT EXISTS (
 SELECT 1 FROM sys.indexes
 WHERE name='IX_core_uwcase_proposer'
   AND object_id=OBJECT_ID('core.core_uw_case')
)
CREATE INDEX IX_core_uwcase_proposer
 ON core.core_uw_case(proposer_entity_id);
GO

IF NOT EXISTS (
 SELECT 1 FROM sys.indexes
 WHERE name='IX_core_uwcase_product'
   AND object_id=OBJECT_ID('core.core_uw_case')
)
CREATE INDEX IX_core_uwcase_product
 ON core.core_uw_case(product_version_id);
GO

-- Event timeline
IF NOT EXISTS (
 SELECT 1 FROM sys.indexes
 WHERE name='IX_core_uwevt_case_time'
   AND object_id=OBJECT_ID('core.core_uw_case_event')
)
CREATE INDEX IX_core_uwevt_case_time
 ON core.core_uw_case_event(uw_case_id, occurred_at);
GO

-- Outcomes
IF NOT EXISTS (
 SELECT 1 FROM sys.indexes
 WHERE name='IX_core_uwro_case'
   AND object_id=OBJECT_ID('core.core_uw_rule_outcome')
)
CREATE INDEX IX_core_uwro_case
 ON core.core_uw_rule_outcome(uw_case_id);
GO

IF NOT EXISTS (
 SELECT 1 FROM sys.indexes
 WHERE name='IX_core_uwro_rulev'
   AND object_id=OBJECT_ID('core.core_uw_rule_outcome')
)
CREATE INDEX IX_core_uwro_rulev
 ON core.core_uw_rule_outcome(rule_version_id);
GO

-- Evidence
IF NOT EXISTS (
 SELECT 1 FROM sys.indexes
 WHERE name='IX_core_uwevd_case'
   AND object_id=OBJECT_ID('core.core_uw_evidence')
)
CREATE INDEX IX_core_uwevd_case
 ON core.core_uw_evidence(uw_case_id);
GO

/* ============================================================
   PRODUCT — PART 2 (WIRING)
   All FKs + practical indexes (idempotent)
   ============================================================ */

-------------------------
-- FOREIGN KEYS
-------------------------

-- Version → Product
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_prodver_product')
ALTER TABLE core.core_product_version
  ADD CONSTRAINT FK_core_prodver_product
  FOREIGN KEY (product_id) REFERENCES core.core_product(product_id);
GO

-- Component → Product Version
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_prodcomp_prodver')
ALTER TABLE core.core_product_component
  ADD CONSTRAINT FK_core_prodcomp_prodver
  FOREIGN KEY (product_version_id) REFERENCES core.core_product_version(product_version_id);
GO

-- Component.coverage_kind_code → ref_coverage_kind
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_prodcomp_covkind')
ALTER TABLE core.core_product_component
  ADD CONSTRAINT FK_core_prodcomp_covkind
  FOREIGN KEY (coverage_kind_code) REFERENCES core.ref_coverage_kind(coverage_kind_code);
GO

-- Option → Component
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_prodopt_component')
ALTER TABLE core.core_product_option
  ADD CONSTRAINT FK_core_prodopt_component
  FOREIGN KEY (component_id) REFERENCES core.core_product_component(component_id);
GO

-- Eligibility → Product Version
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_prodelig_prodver')
ALTER TABLE core.core_product_eligibility_value
  ADD CONSTRAINT FK_core_prodelig_prodver
  FOREIGN KEY (product_version_id) REFERENCES core.core_product_version(product_version_id);
GO

-- Eligibility.lob_attribute_code → ref_lob_attribute
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_prodelig_lobattr')
ALTER TABLE core.core_product_eligibility_value
  ADD CONSTRAINT FK_core_prodelig_lobattr
  FOREIGN KEY (lob_attribute_code) REFERENCES core.ref_lob_attribute(lob_attribute_code);
GO

-- Distribution availability → Product Version
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_proddist_prodver')
ALTER TABLE core.core_product_distribution_availability
  ADD CONSTRAINT FK_core_proddist_prodver
  FOREIGN KEY (product_version_id) REFERENCES core.core_product_version(product_version_id);
GO

-- Regulatory tag → Product Version
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_core_prodrtag_prodver')
ALTER TABLE core.core_product_regulatory_tag
  ADD CONSTRAINT FK_core_prodrtag_prodver
  FOREIGN KEY (product_version_id) REFERENCES core.core_product_version(product_version_id);
GO

-- LoB extensions → Component (1–1)
IF OBJECT_ID('pc.pc_product_component_ext','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_pc_prodcomp_ext_component')
ALTER TABLE pc.pc_product_component_ext
  ADD CONSTRAINT FK_pc_prodcomp_ext_component
  FOREIGN KEY (component_id) REFERENCES core.core_product_component(component_id);
GO

IF OBJECT_ID('lp.lp_product_component_ext','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_prodcomp_ext_component')
ALTER TABLE lp.lp_product_component_ext
  ADD CONSTRAINT FK_lp_prodcomp_ext_component
  FOREIGN KEY (component_id) REFERENCES core.core_product_component(component_id);
GO

IF OBJECT_ID('hlth.hlth_product_component_ext','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_prodcomp_ext_component')
ALTER TABLE hlth.hlth_product_component_ext
  ADD CONSTRAINT FK_hlth_prodcomp_ext_component
  FOREIGN KEY (component_id) REFERENCES core.core_product_component(component_id);
GO

-------------------------
-- INDEXES (natural lookups & joins)
-------------------------

-- Product: common filters by LoB / status
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_core_product_lob_status'
    AND object_id=OBJECT_ID('core.core_product')
)
CREATE INDEX IX_core_product_lob_status
  ON core.core_product(lob_code, status_code, created_at);
GO

-- Product Version: by product and effective dates
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_core_prodver_product'
    AND object_id=OBJECT_ID('core.core_product_version')
)
CREATE INDEX IX_core_prodver_product
  ON core.core_product_version(product_id, effective_from);
GO

-- Component: by version
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_core_prodcomp_version'
    AND object_id=OBJECT_ID('core.core_product_component')
)
CREATE INDEX IX_core_prodcomp_version
  ON core.core_product_component(product_version_id);
GO

-- Option: by component
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_core_prodopt_component'
    AND object_id=OBJECT_ID('core.core_product_option')
)
CREATE INDEX IX_core_prodopt_component
  ON core.core_product_option(component_id);
GO

-- Eligibility: by product_version_id + attribute
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_core_prodelig_ver_attr'
    AND object_id=OBJECT_ID('core.core_product_eligibility_value')
)
CREATE INDEX IX_core_prodelig_ver_attr
  ON core.core_product_eligibility_value(product_version_id, lob_attribute_code);
GO

-- Distribution availability: by version/channel/jurisdiction
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_core_proddist_lookup'
    AND object_id=OBJECT_ID('core.core_product_distribution_availability')
)
CREATE INDEX IX_core_proddist_lookup
  ON core.core_product_distribution_availability(product_version_id, channel_code, jurisdiction_norm, country_code_norm, start_date);
GO

-- Regulatory tag: by version/tag_code
IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_core_prodrtag_ver_tag'
    AND object_id=OBJECT_ID('core.core_product_regulatory_tag')
)
CREATE INDEX IX_core_prodrtag_ver_tag
  ON core.core_product_regulatory_tag(product_version_id, tag_code);
GO

-- LoB extensions: just FK lookups
IF OBJECT_ID('pc.pc_product_component_ext','U') IS NOT NULL
AND NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_pc_prodcomp_ext_component'
    AND object_id=OBJECT_ID('pc.pc_product_component_ext')
)
CREATE INDEX IX_pc_prodcomp_ext_component
  ON pc.pc_product_component_ext(component_id);
GO

IF OBJECT_ID('lp.lp_product_component_ext','U') IS NOT NULL
AND NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_lp_prodcomp_ext_component'
    AND object_id=OBJECT_ID('lp.lp_product_component_ext')
)
CREATE INDEX IX_lp_prodcomp_ext_component
  ON lp.lp_product_component_ext(component_id);
GO

IF OBJECT_ID('hlth.hlth_product_component_ext','U') IS NOT NULL
AND NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name='IX_hlth_prodcomp_ext_component'
    AND object_id=OBJECT_ID('hlth.hlth_product_component_ext')
)
CREATE INDEX IX_hlth_prodcomp_ext_component
  ON hlth.hlth_product_component_ext(component_id);
GO

/* ============================================================
   HEALTH → PROVIDERS (Part 2 — Wiring)
   FKs, CHECKs (one-target, dates, JSON), UNIQUEs, INDEXES
   Idempotent (object_id/name-scoped)
   ============================================================ */

---------------------------------------------------------------
-- Foreign Keys (only intra-domain + core anchors)
---------------------------------------------------------------

-- Provider site → org
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_psite_org')
ALTER TABLE hlth.hlth_provider_site
  ADD CONSTRAINT FK_hlth_psite_org
  FOREIGN KEY (provider_org_id) REFERENCES hlth.hlth_provider_org(provider_org_id);
GO

-- Practitioner → core.entity (PERSON)  [type hygiene handled elsewhere if needed]
IF OBJECT_ID('core.entity','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pprac_entity')
ALTER TABLE hlth.hlth_provider_practitioner
  ADD CONSTRAINT FK_hlth_pprac_entity
  FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

-- Provider org → core.entity (ORG)
IF OBJECT_ID('core.entity','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_porg_entity')
ALTER TABLE hlth.hlth_provider_org
  ADD CONSTRAINT FK_hlth_porg_entity
  FOREIGN KEY (entity_id) REFERENCES core.entity(entity_id);
GO

-- Affiliation → practitioner/org/site
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_paff_prac')
ALTER TABLE hlth.hlth_org_practitioner_affiliation
  ADD CONSTRAINT FK_hlth_paff_prac
  FOREIGN KEY (practitioner_id) REFERENCES hlth.hlth_provider_practitioner(practitioner_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_paff_org')
ALTER TABLE hlth.hlth_org_practitioner_affiliation
  ADD CONSTRAINT FK_hlth_paff_org
  FOREIGN KEY (provider_org_id) REFERENCES hlth.hlth_provider_org(provider_org_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_paff_site')
ALTER TABLE hlth.hlth_org_practitioner_affiliation
  ADD CONSTRAINT FK_hlth_paff_site
  FOREIGN KEY (provider_site_id) REFERENCES hlth.hlth_provider_site(provider_site_id);
GO

-- Network membership → network/org/site/prac
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pnmem_net')
ALTER TABLE hlth.hlth_network_membership
  ADD CONSTRAINT FK_hlth_pnmem_net
  FOREIGN KEY (network_id) REFERENCES hlth.hlth_provider_network(network_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pnmem_org')
ALTER TABLE hlth.hlth_network_membership
  ADD CONSTRAINT FK_hlth_pnmem_org
  FOREIGN KEY (provider_org_id) REFERENCES hlth.hlth_provider_org(provider_org_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pnmem_site')
ALTER TABLE hlth.hlth_network_membership
  ADD CONSTRAINT FK_hlth_pnmem_site
  FOREIGN KEY (provider_site_id) REFERENCES hlth.hlth_provider_site(provider_site_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pnmem_prac')
ALTER TABLE hlth.hlth_network_membership
  ADD CONSTRAINT FK_hlth_pnmem_prac
  FOREIGN KEY (practitioner_id) REFERENCES hlth.hlth_provider_practitioner(practitioner_id);
GO

-- Contract → org/site
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pcon_org')
ALTER TABLE hlth.hlth_provider_contract
  ADD CONSTRAINT FK_hlth_pcon_org
  FOREIGN KEY (provider_org_id) REFERENCES hlth.hlth_provider_org(provider_org_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pcon_site')
ALTER TABLE hlth.hlth_provider_contract
  ADD CONSTRAINT FK_hlth_pcon_site
  FOREIGN KEY (provider_site_id) REFERENCES hlth.hlth_provider_site(provider_site_id);
GO

-- Contract term → contract
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pcont_contract')
ALTER TABLE hlth.hlth_provider_contract_term
  ADD CONSTRAINT FK_hlth_pcont_contract
  FOREIGN KEY (contract_id) REFERENCES hlth.hlth_provider_contract(contract_id);
GO

-- Service catalog → org/site/prac
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_psc_org')
ALTER TABLE hlth.hlth_provider_service_catalog
  ADD CONSTRAINT FK_hlth_psc_org
  FOREIGN KEY (provider_org_id) REFERENCES hlth.hlth_provider_org(provider_org_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_psc_site')
ALTER TABLE hlth.hlth_provider_service_catalog
  ADD CONSTRAINT FK_hlth_psc_site
  FOREIGN KEY (provider_site_id) REFERENCES hlth.hlth_provider_site(provider_site_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_psc_prac')
ALTER TABLE hlth.hlth_provider_service_catalog
  ADD CONSTRAINT FK_hlth_psc_prac
  FOREIGN KEY (practitioner_id) REFERENCES hlth.hlth_provider_practitioner(practitioner_id);
GO

-- Accreditation → org/site/prac
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_paccr_org')
ALTER TABLE hlth.hlth_provider_accreditation
  ADD CONSTRAINT FK_hlth_paccr_org
  FOREIGN KEY (provider_org_id) REFERENCES hlth.hlth_provider_org(provider_org_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_paccr_site')
ALTER TABLE hlth.hlth_provider_accreditation
  ADD CONSTRAINT FK_hlth_paccr_site
  FOREIGN KEY (provider_site_id) REFERENCES hlth.hlth_provider_site(provider_site_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_paccr_prac')
ALTER TABLE hlth.hlth_provider_accreditation
  ADD CONSTRAINT FK_hlth_paccr_prac
  FOREIGN KEY (practitioner_id) REFERENCES hlth.hlth_provider_practitioner(practitioner_id);
GO

-- Exclusion → org/site/prac
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pexcl_org')
ALTER TABLE hlth.hlth_provider_exclusion
  ADD CONSTRAINT FK_hlth_pexcl_org
  FOREIGN KEY (provider_org_id) REFERENCES hlth.hlth_provider_org(provider_org_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pexcl_site')
ALTER TABLE hlth.hlth_provider_exclusion
  ADD CONSTRAINT FK_hlth_pexcl_site
  FOREIGN KEY (provider_site_id) REFERENCES hlth.hlth_provider_site(provider_site_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pexcl_prac')
ALTER TABLE hlth.hlth_provider_exclusion
  ADD CONSTRAINT FK_hlth_pexcl_prac
  FOREIGN KEY (practitioner_id) REFERENCES hlth.hlth_provider_practitioner(practitioner_id);
GO

-- Pre-auth template → network (optional) + rule version (core)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pauth_net')
AND OBJECT_ID('hlth.hlth_provider_network','U') IS NOT NULL
ALTER TABLE hlth.hlth_pre_auth_template
  ADD CONSTRAINT FK_hlth_pauth_net
  FOREIGN KEY (network_id) REFERENCES hlth.hlth_provider_network(network_id);
GO

IF OBJECT_ID('core.ref_uw_rule_version','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_hlth_pauth_rulev')
ALTER TABLE hlth.hlth_pre_auth_template
  ADD CONSTRAINT FK_hlth_pauth_rulev
  FOREIGN KEY (rule_version_id) REFERENCES core.ref_uw_rule_version(rule_version_id);
GO
---------------------------------------------------------------

---------------------------------------------------------------
-- CHECKs (one-target guards, dates, JSON hygiene)
---------------------------------------------------------------

-- Exactly one target in membership/catalog/accreditation/exclusion
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_nmem_one_target')
ALTER TABLE hlth.hlth_network_membership
  ADD CONSTRAINT CK_hlth_nmem_one_target CHECK (
    (CASE WHEN provider_org_id  IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN provider_site_id IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN practitioner_id  IS NOT NULL THEN 1 ELSE 0 END) = 1
  );
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_psc_one_target')
ALTER TABLE hlth.hlth_provider_service_catalog
  ADD CONSTRAINT CK_hlth_psc_one_target CHECK (
    (CASE WHEN provider_org_id  IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN provider_site_id IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN practitioner_id  IS NOT NULL THEN 1 ELSE 0 END) = 1
  );
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_paccr_one_target')
ALTER TABLE hlth.hlth_provider_accreditation
  ADD CONSTRAINT CK_hlth_paccr_one_target CHECK (
    (CASE WHEN provider_org_id  IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN provider_site_id IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN practitioner_id  IS NOT NULL THEN 1 ELSE 0 END) = 1
  );
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_pexcl_one_target')
ALTER TABLE hlth.hlth_provider_exclusion
  ADD CONSTRAINT CK_hlth_pexcl_one_target CHECK (
    (CASE WHEN provider_org_id  IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN provider_site_id IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN practitioner_id  IS NOT NULL THEN 1 ELSE 0 END) = 1
  );
GO

-- Date sanity (basic)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_psite_dates')
ALTER TABLE hlth.hlth_provider_site
  ADD CONSTRAINT CK_hlth_psite_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_pnet_dates')
ALTER TABLE hlth.hlth_provider_network
  ADD CONSTRAINT CK_hlth_pnet_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_pcont_dates')
ALTER TABLE hlth.hlth_provider_contract_term
  ADD CONSTRAINT CK_hlth_pcont_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_pauth_dates')
ALTER TABLE hlth.hlth_pre_auth_template
  ADD CONSTRAINT CK_hlth_pauth_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_psc_dates')
ALTER TABLE hlth.hlth_provider_service_catalog
  ADD CONSTRAINT CK_hlth_psc_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_paccr_dates')
ALTER TABLE hlth.hlth_provider_accreditation
  ADD CONSTRAINT CK_hlth_paccr_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_pexcl_dates')
ALTER TABLE hlth.hlth_provider_exclusion
  ADD CONSTRAINT CK_hlth_pexcl_dates CHECK (effective_to IS NULL OR effective_to >= effective_from);
GO

-- JSON hygiene
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_paff_notes_json')
ALTER TABLE hlth.hlth_org_practitioner_affiliation
  ADD CONSTRAINT CK_hlth_paff_notes_json CHECK (notes_json IS NULL OR ISJSON(notes_json)=1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_pnmem_notes_json')
ALTER TABLE hlth.hlth_network_membership
  ADD CONSTRAINT CK_hlth_pnmem_notes_json CHECK (notes_json IS NULL OR ISJSON(notes_json)=1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_pcont_conditions_json')
ALTER TABLE hlth.hlth_provider_contract_term
  ADD CONSTRAINT CK_hlth_pcont_conditions_json CHECK (conditions_json IS NULL OR ISJSON(conditions_json)=1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_psc_notes_json')
ALTER TABLE hlth.hlth_provider_service_catalog
  ADD CONSTRAINT CK_hlth_psc_notes_json CHECK (notes_json IS NULL OR ISJSON(notes_json)=1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_paccr_details_json')
ALTER TABLE hlth.hlth_provider_accreditation
  ADD CONSTRAINT CK_hlth_paccr_details_json CHECK (details_json IS NULL OR ISJSON(details_json)=1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_pauth_params_json')
ALTER TABLE hlth.hlth_pre_auth_template
  ADD CONSTRAINT CK_hlth_pauth_params_json CHECK (template_params_json IS NULL OR ISJSON(template_params_json)=1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_hlth_pexcl_notes_json')
ALTER TABLE hlth.hlth_provider_exclusion
  ADD CONSTRAINT CK_hlth_pexcl_notes_json CHECK (notes_json IS NULL OR ISJSON(notes_json)=1);
GO
---------------------------------------------------------------

---------------------------------------------------------------
-- UNIQUEs (business keys) & filtered UNIQUEs
---------------------------------------------------------------

-- Network natural key
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_hlth_pnet_code')
ALTER TABLE hlth.hlth_provider_network
  ADD CONSTRAINT UQ_hlth_pnet_code UNIQUE (network_code);
GO

-- Practitioner license unique when present
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_hlth_prac_license'
  AND object_id = OBJECT_ID('hlth.hlth_provider_practitioner'))
CREATE UNIQUE INDEX UX_hlth_prac_license
  ON hlth.hlth_provider_practitioner(license_number)
  WHERE license_number IS NOT NULL;
GO

-- Service catalog de-dup per target + service + effective_from (three filtered uniques)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_hlth_psc_prac'
  AND object_id = OBJECT_ID('hlth.hlth_provider_service_catalog'))
CREATE UNIQUE INDEX UX_hlth_psc_prac
  ON hlth.hlth_provider_service_catalog(practitioner_id, service_code, effective_from)
  WHERE practitioner_id IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_hlth_psc_site'
  AND object_id = OBJECT_ID('hlth.hlth_provider_service_catalog'))
CREATE UNIQUE INDEX UX_hlth_psc_site
  ON hlth.hlth_provider_service_catalog(provider_site_id, service_code, effective_from)
  WHERE provider_site_id IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_hlth_psc_org'
  AND object_id = OBJECT_ID('hlth.hlth_provider_service_catalog'))
CREATE UNIQUE INDEX UX_hlth_psc_org
  ON hlth.hlth_provider_service_catalog(provider_org_id, service_code, effective_from)
  WHERE provider_org_id IS NOT NULL;
GO
---------------------------------------------------------------

---------------------------------------------------------------
-- INDEXES (hot-path joins/lookups)
---------------------------------------------------------------

-- Site/org joins
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_psite_org'
  AND object_id = OBJECT_ID('hlth.hlth_provider_site'))
CREATE INDEX IX_hlth_psite_org
  ON hlth.hlth_provider_site(provider_org_id);
GO

-- Practitioner/entity lookup
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_pprac_entity'
  AND object_id = OBJECT_ID('hlth.hlth_provider_practitioner'))
CREATE INDEX IX_hlth_pprac_entity
  ON hlth.hlth_provider_practitioner(entity_id);
GO

-- Affiliation joins
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_paff_prac'
  AND object_id = OBJECT_ID('hlth.hlth_org_practitioner_affiliation'))
CREATE INDEX IX_hlth_paff_prac
  ON hlth.hlth_org_practitioner_affiliation(practitioner_id, provider_org_id, provider_site_id, effective_from);
GO

-- Network membership joins
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_pnmem_net'
  AND object_id = OBJECT_ID('hlth.hlth_network_membership'))
CREATE INDEX IX_hlth_pnmem_net
  ON hlth.hlth_network_membership(network_id, effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_pnmem_target'
  AND object_id = OBJECT_ID('hlth.hlth_network_membership'))
CREATE INDEX IX_hlth_pnmem_target
  ON hlth.hlth_network_membership(provider_org_id, provider_site_id, practitioner_id);
GO

-- Contract / terms joins
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_pcon_org_site'
  AND object_id = OBJECT_ID('hlth.hlth_provider_contract'))
CREATE INDEX IX_hlth_pcon_org_site
  ON hlth.hlth_provider_contract(provider_org_id, provider_site_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_pcont_contract'
  AND object_id = OBJECT_ID('hlth.hlth_provider_contract_term'))
CREATE INDEX IX_hlth_pcont_contract
  ON hlth.hlth_provider_contract_term(contract_id, effective_from);
GO

-- Service catalog filters
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_psc_service_from'
  AND object_id = OBJECT_ID('hlth.hlth_provider_service_catalog'))
CREATE INDEX IX_hlth_psc_service_from
  ON hlth.hlth_provider_service_catalog(service_code, effective_from);
GO

-- Accreditation lookups
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_paccr_code_from'
  AND object_id = OBJECT_ID('hlth.hlth_provider_accreditation'))
CREATE INDEX IX_hlth_paccr_code_from
  ON hlth.hlth_provider_accreditation(accreditation_code, effective_from);
GO

-- Pre-auth template joins
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_pauth_rulev'
  AND object_id = OBJECT_ID('hlth.hlth_pre_auth_template'))
CREATE INDEX IX_hlth_pauth_rulev
  ON hlth.hlth_pre_auth_template(rule_version_id, service_code);
GO

-- Exclusion filters
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_hlth_pexcl_target_from'
  AND object_id = OBJECT_ID('hlth.hlth_provider_exclusion'))
CREATE INDEX IX_hlth_pexcl_target_from
  ON hlth.hlth_provider_exclusion(provider_org_id, provider_site_id, practitioner_id, effective_from);
GO

/* ============================================================
   LIFE & PENSIONS → PENSIONS — PART 2 (RELATIONSHIPS + INDEXES)
   - All FKs wired here (idempotent)
   - Helpful indexes added (idempotent)
   - Fixes applied:
     • Membership uniqueness now via filtered UNIQUE when policy_id IS NOT NULL
     • Removed redundant IX on scheme_code (unique already exists)
     • Filtered document indexes to skip NULLs
     • Added a few FK-support indexes
   ============================================================ */

-- ############ RELATIONSHIPS (FKs) ############

-- Scheme
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_scheme_type')
ALTER TABLE lp.lp_pension_scheme
  ADD CONSTRAINT FK_lp_scheme_type FOREIGN KEY (scheme_type_code)
  REFERENCES lp.ref_pension_scheme_type(scheme_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_scheme_sponsor')
ALTER TABLE lp.lp_pension_scheme
  ADD CONSTRAINT FK_lp_scheme_sponsor FOREIGN KEY (sponsor_entity_id)
  REFERENCES core.entity(entity_id);
GO

-- Scheme version
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_schemver_scheme')
ALTER TABLE lp.lp_pension_scheme_version
  ADD CONSTRAINT FK_lp_schemver_scheme FOREIGN KEY (scheme_id)
  REFERENCES lp.lp_pension_scheme(scheme_id);
GO

-- Fund catalog
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_fund_scheme')
ALTER TABLE lp.lp_pension_fund_catalog
  ADD CONSTRAINT FK_lp_fund_scheme FOREIGN KEY (scheme_id)
  REFERENCES lp.lp_pension_scheme(scheme_id);
GO

-- Membership
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_mem_scheme')
ALTER TABLE lp.lp_pension_membership
  ADD CONSTRAINT FK_lp_mem_scheme FOREIGN KEY (scheme_id)
  REFERENCES lp.lp_pension_scheme(scheme_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_mem_person')
ALTER TABLE lp.lp_pension_membership
  ADD CONSTRAINT FK_lp_mem_person FOREIGN KEY (person_entity_id)
  REFERENCES core.entity(entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_mem_employer')
ALTER TABLE lp.lp_pension_membership
  ADD CONSTRAINT FK_lp_mem_employer FOREIGN KEY (employer_entity_id)
  REFERENCES core.entity(entity_id);
GO

-- Membership term
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_term_mem')
ALTER TABLE lp.lp_pension_membership_term
  ADD CONSTRAINT FK_lp_term_mem FOREIGN KEY (membership_id)
  REFERENCES lp.lp_pension_membership(membership_id);
GO

-- Contribution schedule
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_sched_mem')
ALTER TABLE lp.lp_pension_contribution_schedule
  ADD CONSTRAINT FK_lp_sched_mem FOREIGN KEY (membership_id)
  REFERENCES lp.lp_pension_membership(membership_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_sched_type')
ALTER TABLE lp.lp_pension_contribution_schedule
  ADD CONSTRAINT FK_lp_sched_type FOREIGN KEY (contribution_type_code)
  REFERENCES lp.ref_contribution_type(contribution_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_sched_freq')
ALTER TABLE lp.lp_pension_contribution_schedule
  ADD CONSTRAINT FK_lp_sched_freq FOREIGN KEY (frequency_code)
  REFERENCES lp.ref_contribution_frequency(frequency_code);
GO

-- Allocation
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_alloc_mem')
ALTER TABLE lp.lp_pension_allocation
  ADD CONSTRAINT FK_lp_alloc_mem FOREIGN KEY (membership_id)
  REFERENCES lp.lp_pension_membership(membership_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_alloc_fund')
ALTER TABLE lp.lp_pension_allocation
  ADD CONSTRAINT FK_lp_alloc_fund FOREIGN KEY (fund_id)
  REFERENCES lp.lp_pension_fund_catalog(fund_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_alloc_method')
ALTER TABLE lp.lp_pension_allocation
  ADD CONSTRAINT FK_lp_alloc_method FOREIGN KEY (allocation_method_code)
  REFERENCES lp.ref_allocation_method(allocation_method_code);
GO

-- Vesting rule
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_vrule_schemver')
ALTER TABLE lp.lp_pension_vesting_rule
  ADD CONSTRAINT FK_lp_vrule_schemver FOREIGN KEY (scheme_version_id)
  REFERENCES lp.lp_pension_scheme_version(scheme_version_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_vrule_type')
ALTER TABLE lp.lp_pension_vesting_rule
  ADD CONSTRAINT FK_lp_vrule_type FOREIGN KEY (vesting_type_code)
  REFERENCES lp.ref_vesting_type(vesting_type_code);
GO

-- Vesting schedule
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_vsched_mem')
ALTER TABLE lp.lp_pension_vesting_schedule
  ADD CONSTRAINT FK_lp_vsched_mem FOREIGN KEY (membership_id)
  REFERENCES lp.lp_pension_membership(membership_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_vsched_rule')
ALTER TABLE lp.lp_pension_vesting_schedule
  ADD CONSTRAINT FK_lp_vsched_rule FOREIGN KEY (source_rule_id)
  REFERENCES lp.lp_pension_vesting_rule(vesting_rule_id);
GO

-- Events
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_event_mem')
ALTER TABLE lp.lp_pension_event
  ADD CONSTRAINT FK_lp_event_mem FOREIGN KEY (membership_id)
  REFERENCES lp.lp_pension_membership(membership_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_event_type')
ALTER TABLE lp.lp_pension_event
  ADD CONSTRAINT FK_lp_event_type FOREIGN KEY (event_type_code)
  REFERENCES lp.ref_pension_event_type(event_type_code);
GO

-- Annuity option
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_aopt_mem')
ALTER TABLE lp.lp_pension_annuity_option
  ADD CONSTRAINT FK_lp_aopt_mem FOREIGN KEY (membership_id)
  REFERENCES lp.lp_pension_membership(membership_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_aopt_ref')
ALTER TABLE lp.lp_pension_annuity_option
  ADD CONSTRAINT FK_lp_aopt_ref FOREIGN KEY (annuity_option_code)
  REFERENCES lp.ref_annuity_option(annuity_option_code);
GO

-- Transfer instruction
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_transf_mem')
ALTER TABLE lp.lp_pension_transfer_instruction
  ADD CONSTRAINT FK_lp_transf_mem FOREIGN KEY (membership_id)
  REFERENCES lp.lp_pension_membership(membership_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_transf_type')
ALTER TABLE lp.lp_pension_transfer_instruction
  ADD CONSTRAINT FK_lp_transf_type FOREIGN KEY (transfer_type_code)
  REFERENCES lp.ref_transfer_type(transfer_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_transf_from')
ALTER TABLE lp.lp_pension_transfer_instruction
  ADD CONSTRAINT FK_lp_transf_from FOREIGN KEY (from_fund_id)
  REFERENCES lp.lp_pension_fund_catalog(fund_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_transf_to')
ALTER TABLE lp.lp_pension_transfer_instruction
  ADD CONSTRAINT FK_lp_transf_to FOREIGN KEY (to_fund_id)
  REFERENCES lp.lp_pension_fund_catalog(fund_id);
GO

-- Documents
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_doc_scheme')
ALTER TABLE lp.lp_pension_document_ref
  ADD CONSTRAINT FK_lp_doc_scheme FOREIGN KEY (scheme_id)
  REFERENCES lp.lp_pension_scheme(scheme_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_doc_mem')
ALTER TABLE lp.lp_pension_document_ref
  ADD CONSTRAINT FK_lp_doc_mem FOREIGN KEY (membership_id)
  REFERENCES lp.lp_pension_membership(membership_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_doc_event')
ALTER TABLE lp.lp_pension_document_ref
  ADD CONSTRAINT FK_lp_doc_event FOREIGN KEY (event_id)
  REFERENCES lp.lp_pension_event(event_id);
GO

-- Extensions
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_memext_mem')
ALTER TABLE lp.lp_pension_membership_ext
  ADD CONSTRAINT FK_lp_memext_mem FOREIGN KEY (membership_id)
  REFERENCES lp.lp_pension_membership(membership_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_eventext_event')
ALTER TABLE lp.lp_pension_event_ext
  ADD CONSTRAINT FK_lp_eventext_event FOREIGN KEY (event_id)
  REFERENCES lp.lp_pension_event(event_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_schemeext_scheme')
ALTER TABLE lp.lp_pension_scheme_ext
  ADD CONSTRAINT FK_lp_schemeext_scheme FOREIGN KEY (scheme_id)
  REFERENCES lp.lp_pension_scheme(scheme_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_lp_schemeext_schemver')
ALTER TABLE lp.lp_pension_scheme_ext
  ADD CONSTRAINT FK_lp_schemeext_schemver FOREIGN KEY (scheme_version_id)
  REFERENCES lp.lp_pension_scheme_version(scheme_version_id);
GO

-- ############ NATURAL/CONTRACT UNIQUENESS (Filtered) ############
-- One membership per (policy, person) when policy_id is present (per-contract rule)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UQ_lp_mem_person_policy'
  AND object_id = OBJECT_ID('lp.lp_pension_membership'))
CREATE UNIQUE INDEX UQ_lp_mem_person_policy
  ON lp.lp_pension_membership(policy_id, person_entity_id)
  WHERE policy_id IS NOT NULL;
GO

-- ############ INDEXES ############

-- Scheme versions
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_schemver_scheme'
  AND object_id=OBJECT_ID('lp.lp_pension_scheme_version'))
CREATE INDEX IX_lp_schemver_scheme ON lp.lp_pension_scheme_version(scheme_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_schemver_from'
  AND object_id=OBJECT_ID('lp.lp_pension_scheme_version'))
CREATE INDEX IX_lp_schemver_from ON lp.lp_pension_scheme_version(effective_from);
GO

-- Funds
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_fund_scheme_code'
  AND object_id=OBJECT_ID('lp.lp_pension_fund_catalog'))
CREATE INDEX IX_lp_fund_scheme_code ON lp.lp_pension_fund_catalog(scheme_id, fund_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_fund_from'
  AND object_id=OBJECT_ID('lp.lp_pension_fund_catalog'))
CREATE INDEX IX_lp_fund_from ON lp.lp_pension_fund_catalog(effective_from);
GO

-- Membership (FK support + common lookups)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_mem_person'
  AND object_id=OBJECT_ID('lp.lp_pension_membership'))
CREATE INDEX IX_lp_mem_person ON lp.lp_pension_membership(person_entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_mem_employer'
  AND object_id=OBJECT_ID('lp.lp_pension_membership'))
CREATE INDEX IX_lp_mem_employer ON lp.lp_pension_membership(employer_entity_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_mem_scheme_policy'
  AND object_id=OBJECT_ID('lp.lp_pension_membership'))
CREATE INDEX IX_lp_mem_scheme_policy ON lp.lp_pension_membership(scheme_id, policy_id);
GO

-- Membership terms
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_term_from'
  AND object_id=OBJECT_ID('lp.lp_pension_membership_term'))
CREATE INDEX IX_lp_term_from ON lp.lp_pension_membership_term(effective_from);
GO

-- Contribution schedules
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_sched_member_from'
  AND object_id=OBJECT_ID('lp.lp_pension_contribution_schedule'))
CREATE INDEX IX_lp_sched_member_from ON lp.lp_pension_contribution_schedule(membership_id, effective_from);
GO

-- Allocations
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_alloc_member_from'
  AND object_id=OBJECT_ID('lp.lp_pension_allocation'))
CREATE INDEX IX_lp_alloc_member_from ON lp.lp_pension_allocation(membership_id, effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_alloc_fund'
  AND object_id=OBJECT_ID('lp.lp_pension_allocation'))
CREATE INDEX IX_lp_alloc_fund ON lp.lp_pension_allocation(fund_id);
GO

-- Vesting rule / schedule
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_vrule_schemver'
  AND object_id=OBJECT_ID('lp.lp_pension_vesting_rule'))
CREATE INDEX IX_lp_vrule_schemver ON lp.lp_pension_vesting_rule(scheme_version_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_vsched_member_date'
  AND object_id=OBJECT_ID('lp.lp_pension_vesting_schedule'))
CREATE INDEX IX_lp_vsched_member_date ON lp.lp_pension_vesting_schedule(membership_id, vesting_date);
GO

-- Events
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_event_member_date'
  AND object_id=OBJECT_ID('lp.lp_pension_event'))
CREATE INDEX IX_lp_event_member_date ON lp.lp_pension_event(membership_id, event_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_event_type'
  AND object_id=OBJECT_ID('lp.lp_pension_event'))
CREATE INDEX IX_lp_event_type ON lp.lp_pension_event(event_type_code);
GO

-- Annuity option
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_aopt_member_from'
  AND object_id=OBJECT_ID('lp.lp_pension_annuity_option'))
CREATE INDEX IX_lp_aopt_member_from ON lp.lp_pension_annuity_option(membership_id, effective_from);
GO

-- Transfers (plus FK support)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_transf_member_date'
  AND object_id=OBJECT_ID('lp.lp_pension_transfer_instruction'))
CREATE INDEX IX_lp_transf_member_date ON lp.lp_pension_transfer_instruction(membership_id, transfer_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_transf_type'
  AND object_id=OBJECT_ID('lp.lp_pension_transfer_instruction'))
CREATE INDEX IX_lp_transf_type ON lp.lp_pension_transfer_instruction(transfer_type_code);
GO

-- Document refs (filtered indexes to skip NULLs)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_doc_scheme'
  AND object_id=OBJECT_ID('lp.lp_pension_document_ref'))
CREATE INDEX IX_lp_doc_scheme ON lp.lp_pension_document_ref(scheme_id)
WHERE scheme_id IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_doc_mem'
  AND object_id=OBJECT_ID('lp.lp_pension_document_ref'))
CREATE INDEX IX_lp_doc_mem ON lp.lp_pension_document_ref(membership_id)
WHERE membership_id IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_lp_doc_event'
  AND object_id=OBJECT_ID('lp.lp_pension_document_ref'))
CREATE INDEX IX_lp_doc_event ON lp.lp_pension_document_ref(event_id)
WHERE event_id IS NOT NULL;
GO

/* ============================================================
   RISK, ACTUARIAL & REINSURANCE → ACTUARIAL (GroupCAT)
   PART 2: RELATIONSHIPS (FKs) & INDEXES — idempotent
   ============================================================ */

/* ---------- Foreign Keys (all intra-rar) ---------- */

/* Aggregation run → model registry */
IF OBJECT_ID('rar.rar_groupcat_aggregation_run','U') IS NOT NULL
AND OBJECT_ID('rar.rar_groupcat_model_ref','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_groupcatrun_model')
ALTER TABLE rar.rar_groupcat_aggregation_run
  ADD CONSTRAINT FK_rar_groupcatrun_model
  FOREIGN KEY (model_id) REFERENCES rar.rar_groupcat_model_ref(model_id);
GO

/* Aggregation run → portfolio selection (optional) */
IF OBJECT_ID('rar.rar_groupcat_aggregation_run','U') IS NOT NULL
AND OBJECT_ID('rar.rar_groupcat_portfolio_selection','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_groupcatrun_sel')
ALTER TABLE rar.rar_groupcat_aggregation_run
  ADD CONSTRAINT FK_rar_groupcatrun_sel
  FOREIGN KEY (selection_id) REFERENCES rar.rar_groupcat_portfolio_selection(selection_id);
GO

/* Agg result → return period reference */
IF OBJECT_ID('rar.rar_groupcat_agg_result','U') IS NOT NULL
AND OBJECT_ID('rar.rar_ref_return_period','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_groupcatres_rp')
ALTER TABLE rar.rar_groupcat_agg_result
  ADD CONSTRAINT FK_rar_groupcatres_rp
  FOREIGN KEY (return_period_years) REFERENCES rar.rar_ref_return_period(return_period_years);
GO

/* Agg result → run header */
IF OBJECT_ID('rar.rar_groupcat_agg_result','U') IS NOT NULL
AND OBJECT_ID('rar.rar_groupcat_aggregation_run','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_groupcatres_run')
ALTER TABLE rar.rar_groupcat_agg_result
  ADD CONSTRAINT FK_rar_groupcatres_run
  FOREIGN KEY (run_id) REFERENCES rar.rar_groupcat_aggregation_run(run_id);
GO

/* ---------- Natural Keys / Uniques ---------- */

/* Model natural identity: (vendor, model_code, version, build) */
IF OBJECT_ID('rar.rar_groupcat_model_ref','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_groupcat_model_nat')
ALTER TABLE rar.rar_groupcat_model_ref
  ADD CONSTRAINT UQ_rar_groupcat_model_nat
  UNIQUE (vendor_code, model_code, version_tag, build_id);
GO

/* Optional uniqueness: portfolio selection name per owner */
IF OBJECT_ID('rar.rar_groupcat_portfolio_selection','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_groupcatps_owner_name')
ALTER TABLE rar.rar_groupcat_portfolio_selection
  ADD CONSTRAINT UQ_rar_groupcatps_owner_name
  UNIQUE (owner_principal, selection_name);
GO

/* ---------- Indexes (hot paths) ---------- */

/* Exposure map: lookup by subject and by cell */
IF OBJECT_ID('rar.rar_groupcat_exposure_map','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_groupcatmap_subject'
  AND object_id = OBJECT_ID('rar.rar_groupcat_exposure_map'))
CREATE INDEX IX_rar_groupcatmap_subject
  ON rar.rar_groupcat_exposure_map(subject_type, subject_key);
GO

IF OBJECT_ID('rar.rar_groupcat_exposure_map','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_groupcatmap_cell'
  AND object_id = OBJECT_ID('rar.rar_groupcat_exposure_map'))
CREATE INDEX IX_rar_groupcatmap_cell
  ON rar.rar_groupcat_exposure_map(cell_key);
GO

/* Aggregation run: support lookups by model and selection */
IF OBJECT_ID('rar.rar_groupcat_aggregation_run','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_groupcatrun_model'
  AND object_id = OBJECT_ID('rar.rar_groupcat_aggregation_run'))
CREATE INDEX IX_rar_groupcatrun_model
  ON rar.rar_groupcat_aggregation_run(model_id);
GO

IF OBJECT_ID('rar.rar_groupcat_aggregation_run','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_groupcatrun_sel'
  AND object_id = OBJECT_ID('rar.rar_groupcat_aggregation_run'))
CREATE INDEX IX_rar_groupcatrun_sel
  ON rar.rar_groupcat_aggregation_run(selection_id);
GO

/* Aggregation result: typical analytics filters */
IF OBJECT_ID('rar.rar_groupcat_agg_result','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_groupcatres_run_ep'
  AND object_id = OBJECT_ID('rar.rar_groupcat_agg_result'))
CREATE INDEX IX_rar_groupcatres_run_ep
  ON rar.rar_groupcat_agg_result(run_id, ep_type_code);
GO

IF OBJECT_ID('rar.rar_groupcat_agg_result','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_groupcatres_rp'
  AND object_id = OBJECT_ID('rar.rar_groupcat_agg_result'))
CREATE INDEX IX_rar_groupcatres_rp
  ON rar.rar_groupcat_agg_result(return_period_years);
GO

/* Peril×Region: simple search helpers */
IF OBJECT_ID('rar.rar_groupcat_peril_region_ref','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_groupcatpr_country'
  AND object_id = OBJECT_ID('rar.rar_groupcat_peril_region_ref'))
CREATE INDEX IX_rar_groupcatpr_country
  ON rar.rar_groupcat_peril_region_ref(country_code);
GO

/* ============================================================
   RAR — ACTUARIAL
   PART 2 — RELATIONSHIPS (FKs), UNIQUEs, INDEXES (guarded)
   ============================================================ */

/* UNIQUEs / Natural keys */
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_as_setkey')
ALTER TABLE rar.rar_act_assumption_set
  ADD CONSTRAINT UQ_rar_act_as_setkey UNIQUE (set_key);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_asv_ver')
ALTER TABLE rar.rar_act_assumption_set_version
  ADD CONSTRAINT UQ_rar_act_asv_ver UNIQUE (assumption_set_id, version_tag);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_dcr_keydate')
ALTER TABLE rar.rar_act_discount_curve_ref
  ADD CONSTRAINT UQ_rar_act_dcr_keydate UNIQUE (curve_key, as_of_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_ycr_keydate')
ALTER TABLE rar.rar_act_yield_curve_ref
  ADD CONSTRAINT UQ_rar_act_ycr_keydate UNIQUE (curve_key, as_of_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_fxset_nat')
ALTER TABLE rar.rar_act_ref_fx_rate_set
  ADD CONSTRAINT UQ_rar_act_fxset_nat UNIQUE (set_key, as_of_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_cg_nat')
ALTER TABLE rar.rar_act_actuarial_contract_group
  ADD CONSTRAINT UQ_rar_act_cg_nat UNIQUE (portfolio_code, cohort_year, measurement_model, onerous_bucket, currency_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_cgri_nat')
ALTER TABLE rar.rar_act_actuarial_contract_group_ri
  ADD CONSTRAINT UQ_rar_act_cgri_nat UNIQUE (portfolio_code, cohort_year, measurement_model, currency_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_pr_runkey')
ALTER TABLE rar.rar_act_projection_run
  ADD CONSTRAINT UQ_rar_act_pr_runkey UNIQUE (run_key);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_mr_runkey')
ALTER TABLE rar.rar_act_measurement_run
  ADD CONSTRAINT UQ_rar_act_mr_runkey UNIQUE (run_key);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_cgmap_nat')
ALTER TABLE rar.rar_act_policy_contract_group_map
  ADD CONSTRAINT UQ_rar_act_cgmap_nat UNIQUE (policy_id, contract_group_id, effective_from);
GO

/* Optional: enforce single CCY per (run, period_start, type) */
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name='UQ_rar_act_pcf_one_ccy')
ALTER TABLE rar.rar_act_projection_cashflow_line
  ADD CONSTRAINT UQ_rar_act_pcf_one_ccy
  UNIQUE (projection_run_id, period_start, cashflow_type_code, currency_code);
GO

/* FOREIGN KEYS */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_asv_set')
ALTER TABLE rar.rar_act_assumption_set_version
  ADD CONSTRAINT FK_rar_act_asv_set FOREIGN KEY (assumption_set_id)
  REFERENCES rar.rar_act_assumption_set(assumption_set_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_dcp_ref')
ALTER TABLE rar.rar_act_discount_curve_point
  ADD CONSTRAINT FK_rar_act_dcp_ref FOREIGN KEY (discount_curve_id)
  REFERENCES rar.rar_act_discount_curve_ref(discount_curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_ycp_ref')
ALTER TABLE rar.rar_act_yield_curve_point
  ADD CONSTRAINT FK_rar_act_ycp_ref FOREIGN KEY (yield_curve_id)
  REFERENCES rar.rar_act_yield_curve_ref(yield_curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_pr_cg')
ALTER TABLE rar.rar_act_projection_run
  ADD CONSTRAINT FK_rar_act_pr_cg FOREIGN KEY (contract_group_id)
  REFERENCES rar.rar_act_actuarial_contract_group(contract_group_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_pr_asv')
ALTER TABLE rar.rar_act_projection_run
  ADD CONSTRAINT FK_rar_act_pr_asv FOREIGN KEY (assumption_version_id)
  REFERENCES rar.rar_act_assumption_set_version(assumption_version_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_pr_dcr')
ALTER TABLE rar.rar_act_projection_run
  ADD CONSTRAINT FK_rar_act_pr_dcr FOREIGN KEY (discount_curve_id)
  REFERENCES rar.rar_act_discount_curve_ref(discount_curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_pr_ycr')
ALTER TABLE rar.rar_act_projection_run
  ADD CONSTRAINT FK_rar_act_pr_ycr FOREIGN KEY (yield_curve_id)
  REFERENCES rar.rar_act_yield_curve_ref(yield_curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_pr_ra')
ALTER TABLE rar.rar_act_projection_run
  ADD CONSTRAINT FK_rar_act_pr_ra FOREIGN KEY (ra_method_id)
  REFERENCES rar.rar_act_risk_adjustment_method(ra_method_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_pr_fx')
ALTER TABLE rar.rar_act_projection_run
  ADD CONSTRAINT FK_rar_act_pr_fx FOREIGN KEY (fx_rate_set_id)
  REFERENCES rar.rar_act_ref_fx_rate_set(fx_rate_set_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_pcf_type')
ALTER TABLE rar.rar_act_projection_cashflow_line
  ADD CONSTRAINT FK_rar_act_pcf_type FOREIGN KEY (cashflow_type_code)
  REFERENCES rar.rar_act_ref_cashflow_type(cashflow_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_pcf_run')
ALTER TABLE rar.rar_act_projection_cashflow_line
  ADD CONSTRAINT FK_rar_act_pcf_run FOREIGN KEY (projection_run_id)
  REFERENCES rar.rar_act_projection_run(projection_run_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_acf_cg')
ALTER TABLE rar.rar_act_actual_cashflow_line
  ADD CONSTRAINT FK_rar_act_acf_cg FOREIGN KEY (contract_group_id)
  REFERENCES rar.rar_act_actuarial_contract_group(contract_group_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_acf_type')
ALTER TABLE rar.rar_act_actual_cashflow_line
  ADD CONSTRAINT FK_rar_act_acf_type FOREIGN KEY (cashflow_type_code)
  REFERENCES rar.rar_act_ref_cashflow_type(cashflow_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_cu_cg')
ALTER TABLE rar.rar_act_coverage_units_period
  ADD CONSTRAINT FK_rar_act_cu_cg FOREIGN KEY (contract_group_id)
  REFERENCES rar.rar_act_actuarial_contract_group(contract_group_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_mr_cg')
ALTER TABLE rar.rar_act_measurement_run
  ADD CONSTRAINT FK_rar_act_mr_cg FOREIGN KEY (contract_group_id)
  REFERENCES rar.rar_act_actuarial_contract_group(contract_group_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_mr_pr')
ALTER TABLE rar.rar_act_measurement_run
  ADD CONSTRAINT FK_rar_act_mr_pr FOREIGN KEY (projection_run_id)
  REFERENCES rar.rar_act_projection_run(projection_run_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_mr_asv')
ALTER TABLE rar.rar_act_measurement_run
  ADD CONSTRAINT FK_rar_act_mr_asv FOREIGN KEY (assumption_version_id)
  REFERENCES rar.rar_act_assumption_set_version(assumption_version_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_mr_dcr')
ALTER TABLE rar.rar_act_measurement_run
  ADD CONSTRAINT FK_rar_act_mr_dcr FOREIGN KEY (discount_curve_id)
  REFERENCES rar.rar_act_discount_curve_ref(discount_curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_mr_ycr')
ALTER TABLE rar.rar_act_measurement_run
  ADD CONSTRAINT FK_rar_act_mr_ycr FOREIGN KEY (yield_curve_id)
  REFERENCES rar.rar_act_yield_curve_ref(yield_curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_mr_ra')
ALTER TABLE rar.rar_act_measurement_run
  ADD CONSTRAINT FK_rar_act_mr_ra FOREIGN KEY (ra_method_id)
  REFERENCES rar.rar_act_risk_adjustment_method(ra_method_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_mr_fx')
ALTER TABLE rar.rar_act_measurement_run
  ADD CONSTRAINT FK_rar_act_mr_fx FOREIGN KEY (fx_rate_set_id)
  REFERENCES rar.rar_act_ref_fx_rate_set(fx_rate_set_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_rf_mr')
ALTER TABLE rar.rar_act_ifrs17_rollforward
  ADD CONSTRAINT FK_rar_act_rf_mr FOREIGN KEY (measurement_run_id)
  REFERENCES rar.rar_act_measurement_run(measurement_run_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_rf_cg')
ALTER TABLE rar.rar_act_ifrs17_rollforward
  ADD CONSTRAINT FK_rar_act_rf_cg FOREIGN KEY (contract_group_id)
  REFERENCES rar.rar_act_actuarial_contract_group(contract_group_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_ea_mr')
ALTER TABLE rar.rar_act_experience_adjustment
  ADD CONSTRAINT FK_rar_act_ea_mr FOREIGN KEY (measurement_run_id)
  REFERENCES rar.rar_act_measurement_run(measurement_run_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_ea_cg')
ALTER TABLE rar.rar_act_experience_adjustment
  ADD CONSTRAINT FK_rar_act_ea_cg FOREIGN KEY (contract_group_id)
  REFERENCES rar.rar_act_actuarial_contract_group(contract_group_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_ea_type')
ALTER TABLE rar.rar_act_experience_adjustment
  ADD CONSTRAINT FK_rar_act_ea_type FOREIGN KEY (cashflow_type_code)
  REFERENCES rar.rar_act_ref_cashflow_type(cashflow_type_code);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_tr_cg')
ALTER TABLE rar.rar_act_transition_setting
  ADD CONSTRAINT FK_rar_act_tr_cg FOREIGN KEY (contract_group_id)
  REFERENCES rar.rar_act_actuarial_contract_group(contract_group_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_mri_cgri')
ALTER TABLE rar.rar_act_ifrs17_measurement_ri
  ADD CONSTRAINT FK_rar_act_mri_cgri FOREIGN KEY (contract_group_ri_id)
  REFERENCES rar.rar_act_actuarial_contract_group_ri(contract_group_ri_id);
GO

/* Optional cross-domain FK to policies */
IF OBJECT_ID('core.core_policy','U') IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name='FK_rar_act_cgmap_policy')
ALTER TABLE rar.rar_act_policy_contract_group_map
  ADD CONSTRAINT FK_rar_act_cgmap_policy FOREIGN KEY (policy_id)
  REFERENCES core.core_policy(policy_id);
GO

/* INDEXES (guarded) */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_cg_portfolio' AND object_id=OBJECT_ID('rar.rar_act_actuarial_contract_group'))
CREATE INDEX IX_rar_act_cg_portfolio ON rar.rar_act_actuarial_contract_group(portfolio_code, cohort_year);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_cgmap_policy_from' AND object_id=OBJECT_ID('rar.rar_act_policy_contract_group_map'))
CREATE INDEX IX_rar_act_cgmap_policy_from ON rar.rar_act_policy_contract_group_map(policy_id, effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_asv_from' AND object_id=OBJECT_ID('rar.rar_act_assumption_set_version'))
CREATE INDEX IX_rar_act_asv_from ON rar.rar_act_assumption_set_version(assumption_set_id, effective_from);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_pr_cg' AND object_id=OBJECT_ID('rar.rar_act_projection_run'))
CREATE INDEX IX_rar_act_pr_cg ON rar.rar_act_projection_run(contract_group_id, as_of_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_pr_asv' AND object_id=OBJECT_ID('rar.rar_act_projection_run'))
CREATE INDEX IX_rar_act_pr_asv ON rar.rar_act_projection_run(assumption_version_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_pr_dcr' AND object_id=OBJECT_ID('rar.rar_act_projection_run'))
CREATE INDEX IX_rar_act_pr_dcr ON rar.rar_act_projection_run(discount_curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_pr_ycr' AND object_id=OBJECT_ID('rar.rar_act_projection_run'))
CREATE INDEX IX_rar_act_pr_ycr ON rar.rar_act_projection_run(yield_curve_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_pr_ra' AND object_id=OBJECT_ID('rar.rar_act_projection_run'))
CREATE INDEX IX_rar_act_pr_ra ON rar.rar_act_projection_run(ra_method_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_pr_fx' AND object_id=OBJECT_ID('rar.rar_act_projection_run'))
CREATE INDEX IX_rar_act_pr_fx ON rar.rar_act_projection_run(fx_rate_set_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_pcf_run' AND object_id=OBJECT_ID('rar.rar_act_projection_cashflow_line'))
CREATE INDEX IX_rar_act_pcf_run ON rar.rar_act_projection_cashflow_line(projection_run_id, period_start);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_acf_cg_date' AND object_id=OBJECT_ID('rar.rar_act_actual_cashflow_line'))
CREATE INDEX IX_rar_act_acf_cg_date ON rar.rar_act_actual_cashflow_line(contract_group_id, period_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_cu_cg_from' AND object_id=OBJECT_ID('rar.rar_act_coverage_units_period'))
CREATE INDEX IX_rar_act_cu_cg_from ON rar.rar_act_coverage_units_period(contract_group_id, period_start);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_mr_cg' AND object_id=OBJECT_ID('rar.rar_act_measurement_run'))
CREATE INDEX IX_rar_act_mr_cg ON rar.rar_act_measurement_run(contract_group_id, as_of_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_mr_pr' AND object_id=OBJECT_ID('rar.rar_act_measurement_run'))
CREATE INDEX IX_rar_act_mr_pr ON rar.rar_act_measurement_run(projection_run_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_rf_mr' AND object_id=OBJECT_ID('rar.rar_act_ifrs17_rollforward'))
CREATE INDEX IX_rar_act_rf_mr ON rar.rar_act_ifrs17_rollforward(measurement_run_id, contract_group_id, period_start);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_ea_mr' AND object_id=OBJECT_ID('rar.rar_act_experience_adjustment'))
CREATE INDEX IX_rar_act_ea_mr ON rar.rar_act_experience_adjustment(measurement_run_id, contract_group_id, period_date);
GO

/* Optional: RI metric lookup */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_rar_act_mri_metric' AND object_id=OBJECT_ID('rar.rar_act_ifrs17_measurement_ri'))
CREATE INDEX IX_rar_act_mri_metric ON rar.rar_act_ifrs17_measurement_ri(metric_code, as_of_date);
GO
