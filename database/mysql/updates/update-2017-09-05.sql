INSERT INTO encounterForm VALUES
  ('OFC-Female Consult', '../form/formConsultLetter.jsp?demographic_no=', 'formConsultLetter', 1),
  ('OFC-Male Consult', '../form/maleconsultletter.jsp?demographic_no=', 'form_male_consult', 2);

CREATE TABLE `formConsultLetter` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `demographic_no` int(10) DEFAULT NULL,
  `provider_no` int(10) DEFAULT NULL,
  `formCreated` date DEFAULT NULL,
  `formEdited` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `consultDate` date DEFAULT NULL,
  `patient_fname` varchar(60) DEFAULT NULL,
  `patient_lname` varchar(60) DEFAULT NULL,
  `patient_age` varchar(15) DEFAULT NULL,
  `partner_fname` varchar(60) DEFAULT NULL,
  `partner_lname` varchar(60) DEFAULT NULL,
  `partner_age` varchar(15) DEFAULT NULL,
  `family_doctor_fname` varchar(60) DEFAULT NULL,
  `family_doctor_lname` varchar(60) DEFAULT NULL,
  `rfc_infertility` tinyint(1) DEFAULT NULL,
  `rfc_rpl` tinyint(1) DEFAULT NULL,
  `rfc_fp` tinyint(1) DEFAULT NULL,
  `rfc_afp` tinyint(1) DEFAULT NULL,
  `rfc_endometriosis` tinyint(1) DEFAULT NULL,
  `rfc_amenorrhea` tinyint(1) DEFAULT NULL,
  `rfc_ros` tinyint(1) DEFAULT NULL,
  `rfc_ps` tinyint(1) DEFAULT NULL,
  `rfc_pcos` tinyint(1) DEFAULT NULL,
  `rfc_pof` tinyint(1) DEFAULT NULL,
  `rfc_tdi` tinyint(1) DEFAULT NULL,
  `rfc_det` tinyint(1) DEFAULT NULL,
  `rfc_mfi` tinyint(1) DEFAULT NULL,
  `rfc_hov` tinyint(1) DEFAULT NULL,
  `rfc_other` text,
  `rfhof_lmp` tinyint(1) DEFAULT NULL,
  `rfhof_lmp_t` varchar(15) DEFAULT NULL,
  `rfhof_gtpaepl` tinyint(1) DEFAULT NULL,
  `rfhof_gtpaepl_gt` varchar(15) DEFAULT NULL,
  `rfhof_gtpaepl_tt` varchar(15) DEFAULT NULL,
  `rfhof_gtpaepl_pt` varchar(15) DEFAULT NULL,
  `rfhof_gtpaepl_at` varchar(15) DEFAULT NULL,
  `rfhof_gtpaepl_ept` varchar(15) DEFAULT NULL,
  `rfhof_gtpaepl_lt` varchar(15) DEFAULT NULL,
  `rfhof_dot` tinyint(1) DEFAULT NULL,
  `rfhof_dot_t` varchar(15) DEFAULT NULL,
  `rfhof_menarche` tinyint(1) DEFAULT NULL,
  `rfhof_menarche_t` varchar(15) DEFAULT NULL,
  `rfhof_other` text,
  `rfhof_ci` tinyint(1) DEFAULT NULL,
  `rfhof_ci_t` varchar(15) DEFAULT NULL,
  `rfhof_ra` tinyint(1) DEFAULT NULL,
  `rfhof_rh` tinyint(1) DEFAULT NULL,
  `rfhof_rg` tinyint(1) DEFAULT NULL,
  `rfhof_other2` text,
  `rfhtf_atd` tinyint(1) DEFAULT NULL,
  `rfhtf_atd_t` varchar(15) DEFAULT NULL,
  `rfhtf_atdd` tinyint(1) DEFAULT NULL,
  `rfhtf_sti` tinyint(1) DEFAULT NULL,
  `rfhtf_pid` tinyint(1) DEFAULT NULL,
  `rfhtf_pid_t` text,
  `rfhtf_pelvsurg` tinyint(1) DEFAULT NULL,
  `rfhtf_pelvsurg_t` text,
  `rfhtf_ectpsurg` tinyint(1) DEFAULT NULL,
  `rfhtf_dtrs` tinyint(1) DEFAULT NULL,
  `rfhtf_other` text,
  `rfhcf_ri` tinyint(1) DEFAULT NULL,
  `rfhcf_ri_t` varchar(15) DEFAULT NULL,
  `rfhcf_pd` tinyint(1) DEFAULT NULL,
  `rfhcf_erd` tinyint(1) DEFAULT NULL,
  `rfhcf_ejd` tinyint(1) DEFAULT NULL,
  `rfhcf_dl` tinyint(1) DEFAULT NULL,
  `rfhcf_nsf` tinyint(1) DEFAULT NULL,
  `rfhcf_lubricants` tinyint(1) DEFAULT NULL,
  `rfhcf_other` text,
  `rfhmf_fp` tinyint(1) DEFAULT NULL,
  `rfhmf_fp_t` varchar(15) DEFAULT NULL,
  `rfhmf_nsa` tinyint(1) DEFAULT NULL,
  `rfhmf_asa` tinyint(1) DEFAULT NULL,
  `rfhmf_asa_t` text,
  `rfhmf_azoospermia` tinyint(1) DEFAULT NULL,
  `rfhmf_hov` tinyint(1) DEFAULT NULL,
  `rfhmf_hov_t` varchar(15) DEFAULT NULL,
  `rfhmf_hovr` tinyint(1) DEFAULT NULL,
  `rfhmf_hovr_t` varchar(15) DEFAULT NULL,
  `rfhmf_hout` tinyint(1) DEFAULT NULL,
  `rfhmf_hout_t` varchar(15) DEFAULT NULL,
  `rfhmf_oat` tinyint(1) DEFAULT NULL,
  `rfhmf_oat_t` varchar(15) DEFAULT NULL,
  `rfhmf_hoo` tinyint(1) DEFAULT NULL,
  `rfhmf_ge` tinyint(1) DEFAULT NULL,
  `rfhmf_ge_t` text,
  `rfhmf_ge_alcohol` tinyint(1) DEFAULT NULL,
  `rfhmf_ge_smoker` tinyint(1) DEFAULT NULL,
  `rfhmf_ge_degreasers` tinyint(1) DEFAULT NULL,
  `rfhmf_ge_marijuana` tinyint(1) DEFAULT NULL,
  `rfhmf_ge_saunas` tinyint(1) DEFAULT NULL,
  `rfhmf_mmh` text,
  `rfhmf_mm` text,
  `rfhmf_ma` text,
  `rfhmf_mfh` text,
  `rfhmf_other` text,
  `pi_tp` tinyint(1) DEFAULT NULL,
  `pi_tp_t` varchar(40) DEFAULT NULL,
  `pi_tp_normal` tinyint(1) DEFAULT NULL,
  `pi_tp_abnormal` tinyint(1) DEFAULT NULL,
  `pi_tp_abnormal_t` text,
  `pi_laparoscopy` tinyint(1) DEFAULT NULL,
  `pi_laparoscopy_t` varchar(40) DEFAULT NULL,
  `pi_lps_normal` tinyint(1) DEFAULT NULL,
  `pi_lps_abnormal` tinyint(1) DEFAULT NULL,
  `pi_lps_abnormal_t` text,
  `pi_lp` tinyint(1) DEFAULT NULL,
  `pi_lp_t` varchar(40) DEFAULT NULL,
  `pi_lp_normal` tinyint(1) DEFAULT NULL,
  `pi_lp_abnormal` tinyint(1) DEFAULT NULL,
  `pi_lp_abnormal_t` text,
  `pi_ha` tinyint(1) DEFAULT NULL,
  `pi_ha_t` varchar(40) DEFAULT NULL,
  `pi_ha_normal` tinyint(1) DEFAULT NULL,
  `pi_ha_abnormal` tinyint(1) DEFAULT NULL,
  `pi_ha_abnormal_t` text,
  `pi_pa` tinyint(1) DEFAULT NULL,
  `pi_pa_t` varchar(40) DEFAULT NULL,
  `pi_pa_normal` tinyint(1) DEFAULT NULL,
  `pi_pa_abnormal` tinyint(1) DEFAULT NULL,
  `pi_pa_abnormal_t` text,
  `pi_sa` tinyint(1) DEFAULT NULL,
  `pi_sa_t` varchar(40) DEFAULT NULL,
  `pi_sa_normal` tinyint(1) DEFAULT NULL,
  `pi_sa_abnormal` tinyint(1) DEFAULT NULL,
  `pi_sa_abnormal_t` text,
  `pi_other` text,
  `pt_oi` tinyint(1) DEFAULT NULL,
  `pt_oi_t` text,
  `pt_saii` tinyint(1) DEFAULT NULL,
  `pt_saii_t` text,
  `pt_ivf` tinyint(1) DEFAULT NULL,
  `pt_ivf_t` text,
  `pt_ivf_icsi` tinyint(1) DEFAULT NULL,
  `pt_ivf_icsi_t` text,
  `pt_other` text,
  `oh_year1` varchar(15) DEFAULT NULL,
  `oh_po1` varchar(15) DEFAULT NULL,
  `oh_weeks1` varchar(15) DEFAULT NULL,
  `oh_treatment1` text,
  `oh_toc1` varchar(15) DEFAULT NULL,
  `oh_notes1` text,
  `oh_year2` varchar(15) DEFAULT NULL,
  `oh_po2` varchar(15) DEFAULT NULL,
  `oh_weeks2` varchar(15) DEFAULT NULL,
  `oh_treatment2` text,
  `oh_toc2` varchar(15) DEFAULT NULL,
  `oh_notes2` text,
  `oh_year3` varchar(15) DEFAULT NULL,
  `oh_po3` varchar(15) DEFAULT NULL,
  `oh_weeks3` varchar(15) DEFAULT NULL,
  `oh_treatment3` text,
  `oh_toc3` varchar(15) DEFAULT NULL,
  `oh_notes3` text,
  `oh_year4` varchar(15) DEFAULT NULL,
  `oh_po4` varchar(15) DEFAULT NULL,
  `oh_weeks4` varchar(15) DEFAULT NULL,
  `oh_treatment4` text,
  `oh_toc4` varchar(15) DEFAULT NULL,
  `oh_notes4` text,
  `oh_year5` varchar(15) DEFAULT NULL,
  `oh_po5` varchar(15) DEFAULT NULL,
  `oh_weeks5` varchar(15) DEFAULT NULL,
  `oh_treatment5` text,
  `oh_toc5` varchar(15) DEFAULT NULL,
  `oh_notes5` text,
  `oh_year6` varchar(15) DEFAULT NULL,
  `oh_po6` varchar(15) DEFAULT NULL,
  `oh_weeks6` varchar(15) DEFAULT NULL,
  `oh_treatment6` text,
  `oh_toc6` varchar(15) DEFAULT NULL,
  `oh_notes6` text,
  `oh_year7` varchar(15) DEFAULT NULL,
  `oh_po7` varchar(15) DEFAULT NULL,
  `oh_weeks7` varchar(15) DEFAULT NULL,
  `oh_treatment7` text,
  `oh_toc7` varchar(15) DEFAULT NULL,
  `oh_notes7` text,
  `oh_year8` varchar(15) DEFAULT NULL,
  `oh_po8` varchar(15) DEFAULT NULL,
  `oh_weeks8` varchar(15) DEFAULT NULL,
  `oh_treatment8` text,
  `oh_toc8` varchar(15) DEFAULT NULL,
  `oh_notes8` text,
  `oh_year9` varchar(15) DEFAULT NULL,
  `oh_po9` varchar(15) DEFAULT NULL,
  `oh_weeks9` varchar(15) DEFAULT NULL,
  `oh_treatment9` text,
  `oh_toc9` varchar(15) DEFAULT NULL,
  `oh_notes9` text,
  `oh_year10` varchar(15) DEFAULT NULL,
  `oh_po10` varchar(15) DEFAULT NULL,
  `oh_weeks10` varchar(15) DEFAULT NULL,
  `oh_treatment10` text,
  `oh_toc10` varchar(15) DEFAULT NULL,
  `oh_notes10` text,
  `mash_t` text,
  `pam_t` text,
  `allergies_t` text,
  `fh_t` text,
  `sh_occupation` tinyint(1) DEFAULT NULL,
  `sh_occupation_t` text,
  `sh_smoker` tinyint(1) DEFAULT NULL,
  `sh_smoker_t` varchar(15) DEFAULT NULL,
  `sh_alcohol` tinyint(1) DEFAULT NULL,
  `sh_alcohol_t` varchar(15) DEFAULT NULL,
  `sh_drugs` tinyint(1) DEFAULT NULL,
  `sh_drugs_t` varchar(15) DEFAULT NULL,
  `sh_other` text,
  `pe_ht` tinyint(1) DEFAULT NULL,
  `pe_ht_t` varchar(15) DEFAULT NULL,
  `pe_inch_t` varchar(15) DEFAULT NULL,
  `pe_ht_uom_t` varchar(15) DEFAULT NULL,
  `pe_weight` tinyint(1) DEFAULT NULL,
  `pe_weight_t` varchar(15) DEFAULT NULL,
  `pe_weight_uom_t` varchar(15) DEFAULT NULL,
  `pe_bmi` tinyint(1) DEFAULT NULL,
  `pe_bmi_t` varchar(15) DEFAULT NULL,
  `pe_bp` tinyint(1) DEFAULT NULL,
  `pe_bp_t` varchar(15) DEFAULT NULL,
  `pe_ngpe` tinyint(1) DEFAULT NULL,
  `pe_gpef` tinyint(1) DEFAULT NULL,
  `pe_gpef_t` text,
  `pe_npe` tinyint(1) DEFAULT NULL,
  `pe_pef` tinyint(1) DEFAULT NULL,
  `pe_pef_t` text,
  `pe_rt_testicle_size` varchar(15) DEFAULT NULL,
  `pe_rt_testicle_vas` varchar(15) DEFAULT NULL,
  `pe_rt_testicle_varicocele` varchar(15) DEFAULT NULL,
  `pe_lt_testicle_size` varchar(15) DEFAULT NULL,
  `pe_lt_testicle_vas` varchar(15) DEFAULT NULL,
  `pe_lt_testicle_varicocele` varchar(15) DEFAULT NULL,
  `pe_other` text,
  `impression_piue` tinyint(1) DEFAULT NULL,
  `impression_siue` tinyint(1) DEFAULT NULL,
  `impression_rplue` tinyint(1) DEFAULT NULL,
  `impression_od` tinyint(1) DEFAULT NULL,
  `impression_od_t` text,
  `impression_pcos` tinyint(1) DEFAULT NULL,
  `impression_dor` tinyint(1) DEFAULT NULL,
  `impression_ama` tinyint(1) DEFAULT NULL,
  `impression_poi` tinyint(1) DEFAULT NULL,
  `impression_tfi` tinyint(1) DEFAULT NULL,
  `impression_mfi` tinyint(1) DEFAULT NULL,
  `impression_cfi` tinyint(1) DEFAULT NULL,
  `impression_azoospermia` tinyint(1) DEFAULT NULL,
  `impression_ha` tinyint(1) DEFAULT NULL,
  `impression_sfrdp` tinyint(1) DEFAULT NULL,
  `impression_sscrds` tinyint(1) DEFAULT NULL,
  `impression_fo` tinyint(1) DEFAULT NULL,
  `impression_mo` tinyint(1) DEFAULT NULL,
  `impression_rfsc` tinyint(1) DEFAULT NULL,
  `impression_rfsc_t` text,
  `impression_rfoc` tinyint(1) DEFAULT NULL,
  `impression_rfoc_t` text,
  `impression_other` text,
  `optd_em` tinyint(1) DEFAULT NULL,
  `optd_oiv` tinyint(1) DEFAULT NULL,
  `optd_oiv_t` text,
  `optd_saii` tinyint(1) DEFAULT NULL,
  `optd_ivf` tinyint(1) DEFAULT NULL,
  `optd_ivficsi` tinyint(1) DEFAULT NULL,
  `optd_ivficsi_tse` tinyint(1) DEFAULT NULL,
  `optd_laparoscopy` tinyint(1) DEFAULT NULL,
  `optd_myomectomy` tinyint(1) DEFAULT NULL,
  `optd_dsi` tinyint(1) DEFAULT NULL,
  `optd_det` tinyint(1) DEFAULT NULL,
  `optd_rotl` tinyint(1) DEFAULT NULL,
  `optd_vr` tinyint(1) DEFAULT NULL,
  `optd_lc` tinyint(1) DEFAULT NULL,
  `optd_wl` tinyint(1) DEFAULT NULL,
  `optd_adoption` tinyint(1) DEFAULT NULL,
  `optd_sc` tinyint(1) DEFAULT NULL,
  `optd_oc` tinyint(1) DEFAULT NULL,
  `optd_ec` tinyint(1) DEFAULT NULL,
  `optd_oswga` tinyint(1) DEFAULT NULL,
  `optd_other` text,
  `io_3hp` tinyint(1) DEFAULT NULL,
  `io_lpp` tinyint(1) DEFAULT NULL,
  `io_buafc` tinyint(1) DEFAULT NULL,
  `io_tpu` tinyint(1) DEFAULT NULL,
  `io_siuauc` tinyint(1) DEFAULT NULL,
  `io_ids` tinyint(1) DEFAULT NULL,
  `io_sa` tinyint(1) DEFAULT NULL,
  `io_ksa` tinyint(1) DEFAULT NULL,
  `io_apat` tinyint(1) DEFAULT NULL,
  `io_tt` tinyint(1) DEFAULT NULL,
  `io_karyotype` tinyint(1) DEFAULT NULL,
  `io_mhp` tinyint(1) DEFAULT NULL,
  `io_su` tinyint(1) DEFAULT NULL,
  `io_tu` tinyint(1) DEFAULT NULL,
  `io_mcf` tinyint(1) DEFAULT NULL,
  `io_myk` tinyint(1) DEFAULT NULL,
  `io_other` text,
  `tp_em` tinyint(1) DEFAULT NULL,
  `tp_em_t` varchar(15) DEFAULT NULL,
  `tp_oiv` tinyint(1) DEFAULT NULL,
  `tp_oiv_t` text,
  `tp_saii` tinyint(1) DEFAULT NULL,
  `tp_ivf` tinyint(1) DEFAULT NULL,
  `tp_ivficsi` tinyint(1) DEFAULT NULL,
  `tp_ivficsi_tse` tinyint(1) DEFAULT NULL,
  `tp_laparoscopy` tinyint(1) DEFAULT NULL,
  `tp_myomectomy` tinyint(1) DEFAULT NULL,
  `tp_dsi` tinyint(1) DEFAULT NULL,
  `tp_det` tinyint(1) DEFAULT NULL,
  `tp_rotl` tinyint(1) DEFAULT NULL,
  `tp_vr` tinyint(1) DEFAULT NULL,
  `tp_lc` tinyint(1) DEFAULT NULL,
  `tp_wl` tinyint(1) DEFAULT NULL,
  `tp_adoption` tinyint(1) DEFAULT NULL,
  `tp_sc` tinyint(1) DEFAULT NULL,
  `tp_oc` tinyint(1) DEFAULT NULL,
  `tp_ec` tinyint(1) DEFAULT NULL,
  `tp_oswga` tinyint(1) DEFAULT NULL,
  `tp_ru` tinyint(1) DEFAULT NULL,
  `tp_followup` tinyint(1) DEFAULT NULL,
  `tp_other` text,
  `rfc_ivf` tinyint(1) DEFAULT NULL,
  `rfhof_dof` tinyint(1) DEFAULT NULL,
  `rfhof_dof_t` varchar(5) DEFAULT NULL,
  `rfhof_fl` tinyint(1) DEFAULT NULL,
  `rfhof_fl_t` varchar(10) DEFAULT NULL,
  `rfhtf_sti_t` varchar(60) DEFAULT NULL,
  `rfhtf_sti_no` tinyint(1) DEFAULT NULL,
  `rfhtf_ectpsurg_t` varchar(60) DEFAULT NULL,
  `rfhtf_prev_iud` tinyint(1) DEFAULT NULL,
  `rfhcf_pd_no` tinyint(1) DEFAULT NULL,
  `rfhcf_dl_f` tinyint(1) DEFAULT NULL,
  `rfhcf_lubricants_no` tinyint(1) unsigned DEFAULT NULL,
  `rfhmf_ge_alcohol_t` varchar(2) DEFAULT NULL,
  `rfhmf_ge_smoker_non` tinyint(1) unsigned DEFAULT NULL,
  `rfhmf_ge_saunas_d` tinyint(1) unsigned DEFAULT NULL,
  `pe_nthe` tinyint(1) unsigned DEFAULT NULL,
  `pe_naus` tinyint(1) unsigned DEFAULT NULL,
  `pe_nabde` tinyint(1) unsigned DEFAULT NULL,
  `impression_endo` tinyint(1) unsigned DEFAULT NULL,
  `impression_azoospermia_t` varchar(2) DEFAULT NULL,
  `impression_pi` tinyint(1) unsigned DEFAULT NULL,
  `impression_si` tinyint(1) unsigned DEFAULT NULL,
  `impression_azoospermia_o` tinyint(1) unsigned DEFAULT NULL,
  `rfhmf_ge_marijuana_t` varchar(35) DEFAULT NULL,
  `rfhmf_ge_smoker_t` varchar(35) DEFAULT NULL,
  `sh_non_smoker` tinyint(1) unsigned DEFAULT NULL,
  `rfhof_ra_d` tinyint(1) unsigned DEFAULT NULL,
  `rfhof_rh_d` tinyint(1) unsigned DEFAULT NULL,
  `rfhof_rg_d` tinyint(1) unsigned DEFAULT NULL,
  `rfhof_gtpaepl_tat` varchar(15) DEFAULT NULL,
  `impression_azoospermia_n_o` tinyint(1) unsigned DEFAULT NULL,
  `rfhmf_maleocc` tinyint(1) DEFAULT NULL,
  `rfhmf_maleocc_t` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=82918 DEFAULT CHARSET=latin1;

CREATE TABLE `form_male_consult` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `demographic_no` int(10) unsigned DEFAULT NULL,
  `provider_no` int(10) unsigned DEFAULT NULL,
  `formCreated` datetime DEFAULT NULL,
  `formEdited` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pci_date` date DEFAULT NULL,
  `pci_patient_lname` varchar(100) DEFAULT NULL,
  `pci_patient_fname` varchar(100) DEFAULT NULL,
  `pci_patient_age` varchar(3) DEFAULT NULL,
  `pci_partner_lname` varchar(100) DEFAULT NULL,
  `pci_partner_fname` varchar(100) DEFAULT NULL,
  `pci_partner_age` varchar(3) DEFAULT NULL,
  `rfr_male_factor` tinyint(1) unsigned DEFAULT NULL,
  `rfr_infertility` tinyint(1) unsigned DEFAULT NULL,
  `rfr_oligospermia` tinyint(1) unsigned DEFAULT NULL,
  `rfr_oligo_astheno` tinyint(1) unsigned DEFAULT NULL,
  `rfr_asthenospermia` tinyint(1) unsigned DEFAULT NULL,
  `rfr_teratospermia` tinyint(1) unsigned DEFAULT NULL,
  `rfr_oligo_astheno_t` tinyint(1) unsigned DEFAULT NULL,
  `rfr_azoospermia` tinyint(1) unsigned DEFAULT NULL,
  `rfr_testicular_failure` tinyint(1) unsigned DEFAULT NULL,
  `rfr_history_of_vas` tinyint(1) unsigned DEFAULT NULL,
  `rfr_sperm_cryopre` tinyint(1) unsigned DEFAULT NULL,
  `rfr_therapeutic_donor` tinyint(1) unsigned DEFAULT NULL,
  `rfr_erectile_dysfunct` tinyint(1) unsigned DEFAULT NULL,
  `rfr_retrograde_ejacul` tinyint(1) unsigned DEFAULT NULL,
  `rfr_ejaculatory_dys` tinyint(1) unsigned DEFAULT NULL,
  `rfr_decreased_libi` tinyint(1) unsigned DEFAULT NULL,
  `rfr_varicocele` tinyint(1) unsigned DEFAULT NULL,
  `rfr_assessment_of_fert` tinyint(1) unsigned DEFAULT NULL,
  `rfr_other` text,
  `rfh_duration_of_try` tinyint(1) unsigned DEFAULT NULL,
  `rfh_duration_of_try_t` varchar(100) DEFAULT NULL,
  `rfh_frequency_of_inter` tinyint(1) unsigned DEFAULT NULL,
  `rfh_frequency_of_inter_t` varchar(100) DEFAULT NULL,
  `rfh_fathered_pregn` tinyint(1) unsigned DEFAULT NULL,
  `rfh_fathered_pregn_t` varchar(100) DEFAULT NULL,
  `rfh_longest_time_to` tinyint(1) unsigned DEFAULT NULL,
  `rfh_longest_time_to_t` varchar(100) DEFAULT NULL,
  `rfh_erectile_dys` tinyint(1) unsigned DEFAULT NULL,
  `rfh_erectile_dys_t` varchar(100) DEFAULT NULL,
  `rfh_ejaculatory_dys` tinyint(1) unsigned DEFAULT NULL,
  `rfh_ejaculatory_dys_t` varchar(100) DEFAULT NULL,
  `rfh_shaves` tinyint(1) unsigned DEFAULT NULL,
  `rfh_shaves_t` varchar(100) DEFAULT NULL,
  `rfh_vasectomy_done` tinyint(1) unsigned DEFAULT NULL,
  `rfh_vasectomy_done_t` varchar(100) DEFAULT NULL,
  `rfh_vasectomy_rev` tinyint(1) unsigned DEFAULT NULL,
  `rfh_vasectomy_rev_t` varchar(100) DEFAULT NULL,
  `rfh_history_of_unde` tinyint(1) unsigned DEFAULT NULL,
  `rfh_history_of_unde_t` varchar(100) DEFAULT NULL,
  `rfh_orchipexy_at` tinyint(1) unsigned DEFAULT NULL,
  `rfh_orchipexy_at_t` varchar(100) DEFAULT NULL,
  `rfh_history_of_orch` tinyint(1) unsigned DEFAULT NULL,
  `rfh_history_of_scr` tinyint(1) unsigned DEFAULT NULL,
  `rfh_history_of_scr_t` varchar(100) DEFAULT NULL,
  `rfh_history_of_pro` tinyint(1) unsigned DEFAULT NULL,
  `rfh_history_of_epi` tinyint(1) unsigned DEFAULT NULL,
  `rfh_history_of_ure` tinyint(1) unsigned DEFAULT NULL,
  `rfh_inguinal_hern` tinyint(1) unsigned DEFAULT NULL,
  `rfh_gonadotoxic_exp` tinyint(1) unsigned DEFAULT NULL,
  `rfh_gonadotoxic_exp_t` varchar(100) DEFAULT NULL,
  `rfh_other` text,
  `rfh_alcoholic_drinks` tinyint(1) unsigned DEFAULT NULL,
  `rfh_alcoholic_drinks_t` varchar(100) DEFAULT NULL,
  `rfh_marijuana` tinyint(1) unsigned DEFAULT NULL,
  `rfh_marijuana_t` varchar(100) DEFAULT NULL,
  `rfh_smoker` tinyint(1) unsigned DEFAULT NULL,
  `rfh_smoker_t` varchar(100) DEFAULT NULL,
  `rfh_non_smoker` tinyint(1) unsigned DEFAULT NULL,
  `rfh_hot_tubes_sauna` tinyint(1) unsigned DEFAULT NULL,
  `rfh_denies_hot_tubes` tinyint(1) unsigned DEFAULT NULL,
  `rfh_degreasers` tinyint(1) unsigned DEFAULT NULL,
  `previ_normal_semen` tinyint(1) unsigned DEFAULT NULL,
  `previ_abnormal_semen` tinyint(1) unsigned DEFAULT NULL,
  `previ_abnormal_semen_t` varchar(100) DEFAULT NULL,
  `previ_DNA_frag` tinyint(1) unsigned DEFAULT NULL,
  `previ_DNA_frag_t` varchar(100) DEFAULT NULL,
  `previ_azoospermia` tinyint(1) unsigned DEFAULT NULL,
  `previ_scrotal_ultr` tinyint(1) unsigned DEFAULT NULL,
  `previ_scrotal_ultr_t` varchar(100) DEFAULT NULL,
  `previ_transrectal_ult` tinyint(1) unsigned DEFAULT NULL,
  `previ_transrectal_ult_t` varchar(100) DEFAULT NULL,
  `previ_hormones` tinyint(1) unsigned DEFAULT NULL,
  `previ_hormones_t` varchar(100) DEFAULT NULL,
  `previ_y_micro` tinyint(1) unsigned DEFAULT NULL,
  `previ_karyotype` tinyint(1) unsigned DEFAULT NULL,
  `previ_CFTR` tinyint(1) unsigned DEFAULT NULL,
  `previ_other` text,
  `msh_t` text,
  `pm_t` text,
  `alle_t` text,
  `fh_t` text,
  `sh_occupation` tinyint(1) unsigned DEFAULT NULL,
  `sh_t` varchar(100) DEFAULT NULL,
  `fh_age` tinyint(1) unsigned DEFAULT NULL,
  `fh_age_t` varchar(3) DEFAULT NULL,
  `fh_gpep` tinyint(1) unsigned DEFAULT NULL,
  `fh_g_t` varchar(3) DEFAULT NULL,
  `fh_p_t` varchar(3) DEFAULT NULL,
  `fh_ep_t` varchar(3) DEFAULT NULL,
  `fh_a_t` varchar(3) DEFAULT NULL,
  `fh_l_t` varchar(3) DEFAULT NULL,
  `fh_preg_with_cur` tinyint(1) unsigned DEFAULT NULL,
  `fh_preg_with_cur_t` varchar(3) DEFAULT NULL,
  `fh_preg_with_prev` tinyint(1) unsigned DEFAULT NULL,
  `fh_preg_with_prev_t` varchar(3) DEFAULT NULL,
  `fh_gynec` tinyint(1) unsigned DEFAULT NULL,
  `fh_gynec_t` varchar(100) DEFAULT NULL,
  `fh_other` text,
  `pft_ovul_induct` tinyint(1) unsigned DEFAULT NULL,
  `pft_ovul_induct_t` varchar(100) DEFAULT NULL,
  `pft_superov_IUI` tinyint(1) unsigned DEFAULT NULL,
  `pft_superov_IUI_t` varchar(100) DEFAULT NULL,
  `pft_IUI` tinyint(1) unsigned DEFAULT NULL,
  `pft_IUI_t` varchar(100) DEFAULT NULL,
  `pft_IVF` tinyint(1) unsigned DEFAULT NULL,
  `pft_IVF_t` varchar(100) DEFAULT NULL,
  `pft_IVF_ICSI` tinyint(1) unsigned DEFAULT NULL,
  `pft_IVF_ICSI_t` varchar(100) DEFAULT NULL,
  `pft_donor_sperm_ins` tinyint(1) unsigned DEFAULT NULL,
  `pft_HMG` tinyint(1) unsigned DEFAULT NULL,
  `pft_HMG_t` varchar(100) DEFAULT NULL,
  `pft_HCG` tinyint(1) unsigned DEFAULT NULL,
  `pft_HCG_t` varchar(100) DEFAULT NULL,
  `pft_other` text,
  `pem_ht` tinyint(1) unsigned DEFAULT NULL,
  `pem_ht_t` varchar(5) DEFAULT NULL,
  `pem_wt` tinyint(1) unsigned DEFAULT NULL,
  `pem_wt_t` varchar(5) DEFAULT NULL,
  `pem_BMI` tinyint(1) unsigned DEFAULT NULL,
  `pem_BMI_t` varchar(6) DEFAULT NULL,
  `pem_normal_gen_phy` tinyint(1) unsigned DEFAULT NULL,
  `pem_normal_andro` tinyint(1) unsigned DEFAULT NULL,
  `pem_gen_phys_exam_fi` tinyint(1) unsigned DEFAULT NULL,
  `pem_gen_phys_exam_fi_t` varchar(100) DEFAULT NULL,
  `pemp_l_size` tinyint(1) unsigned DEFAULT NULL,
  `pemp_l_size_t` varchar(6) DEFAULT NULL,
  `pemp_l_vas` tinyint(1) unsigned DEFAULT NULL,
  `pemp_l_vas_t` varchar(5) DEFAULT NULL,
  `pemp_l_varic_grade` tinyint(1) unsigned DEFAULT NULL,
  `pemp_l_varic_grade_t` varchar(5) DEFAULT NULL,
  `pemp_r_size` tinyint(1) unsigned DEFAULT NULL,
  `pemp_r_size_t` varchar(6) DEFAULT NULL,
  `pemp_r_vas` tinyint(1) unsigned DEFAULT NULL,
  `pemp_r_vas_t` varchar(5) DEFAULT NULL,
  `pemp_r_varic_grade` tinyint(1) unsigned DEFAULT NULL,
  `pemp_r_varic_grade_t` varchar(5) DEFAULT NULL,
  `pemp_other` text,
  `impr_prim_infer_eti` tinyint(1) unsigned DEFAULT NULL,
  `impr_secon_infer_eti` tinyint(1) unsigned DEFAULT NULL,
  `impr_male_factor_inf` tinyint(1) unsigned DEFAULT NULL,
  `impr_oligospe` tinyint(1) unsigned DEFAULT NULL,
  `impr_oligo_asth` tinyint(1) unsigned DEFAULT NULL,
  `impr_astheno` tinyint(1) unsigned DEFAULT NULL,
  `impr_terato` tinyint(1) unsigned DEFAULT NULL,
  `impr_oligo_ast_tera` tinyint(1) unsigned DEFAULT NULL,
  `impr_advan_pat_age` tinyint(1) unsigned DEFAULT NULL,
  `impr_coital_fact_inf` tinyint(1) unsigned DEFAULT NULL,
  `impr_erectile_dys` tinyint(1) unsigned DEFAULT NULL,
  `impr_retro_ejac` tinyint(1) unsigned DEFAULT NULL,
  `impr_varico` tinyint(1) unsigned DEFAULT NULL,
  `impr_hypot_dysf` tinyint(1) unsigned DEFAULT NULL,
  `impr_test_fail` tinyint(1) unsigned DEFAULT NULL,
  `impr_y_microd` tinyint(1) unsigned DEFAULT NULL,
  `impr_kline_syndr` tinyint(1) unsigned DEFAULT NULL,
  `impr_cong_bil_abs` tinyint(1) unsigned DEFAULT NULL,
  `impr_azoospermia` tinyint(1) unsigned DEFAULT NULL,
  `impr_obstr_azoo` tinyint(1) unsigned DEFAULT NULL,
  `impr_non_obstr_azoo` tinyint(1) unsigned DEFAULT NULL,
  `impr_epid_obstr` tinyint(1) unsigned DEFAULT NULL,
  `impr_male_obe` tinyint(1) unsigned DEFAULT NULL,
  `impr_hyperprola` tinyint(1) unsigned DEFAULT NULL,
  `impr_req_sperm_cry` tinyint(1) unsigned DEFAULT NULL,
  `impr_req_sperm_cry_t` varchar(100) DEFAULT NULL,
  `impr_other` text,
  `optd_expec_manage` tinyint(1) unsigned DEFAULT NULL,
  `optd_superov_intr` tinyint(1) unsigned DEFAULT NULL,
  `optd_IVF_ICSI` tinyint(1) unsigned DEFAULT NULL,
  `optd_IVF_ICSI_test` tinyint(1) unsigned DEFAULT NULL,
  `optd_IVF_ICSI_micro` tinyint(1) unsigned DEFAULT NULL,
  `optd_scrotal_exp_pos` tinyint(1) unsigned DEFAULT NULL,
  `optd_vasec_reve` tinyint(1) unsigned DEFAULT NULL,
  `optd_vari_rep` tinyint(1) unsigned DEFAULT NULL,
  `optd_gonado_ther` tinyint(1) unsigned DEFAULT NULL,
  `optd_clomi_ther` tinyint(1) unsigned DEFAULT NULL,
  `optd_antic_ther` tinyint(1) unsigned DEFAULT NULL,
  `optd_antic_ther_t` varchar(100) DEFAULT NULL,
  `optd_donor_sperm_ins` tinyint(1) unsigned DEFAULT NULL,
  `optd_lifestyle_ch` tinyint(1) unsigned DEFAULT NULL,
  `optd_weight_loss` tinyint(1) unsigned DEFAULT NULL,
  `optd_adoption` tinyint(1) unsigned DEFAULT NULL,
  `optd_sperm_cryopr` tinyint(1) unsigned DEFAULT NULL,
  `optd_other` text,
  `invo_horm_prof` tinyint(1) unsigned DEFAULT NULL,
  `invo_semen_analysis` tinyint(1) unsigned DEFAULT NULL,
  `invo_repeat_semen` tinyint(1) unsigned DEFAULT NULL,
  `invo_kruger_semen` tinyint(1) unsigned DEFAULT NULL,
  `invo_DNA_frag` tinyint(1) unsigned DEFAULT NULL,
  `invo_scrotal_ultra` tinyint(1) unsigned DEFAULT NULL,
  `invo_trans_ultr` tinyint(1) unsigned DEFAULT NULL,
  `invo_male_CF` tinyint(1) unsigned DEFAULT NULL,
  `invo_y_micro` tinyint(1) unsigned DEFAULT NULL,
  `invo_karyotype` tinyint(1) unsigned DEFAULT NULL,
  `invo_head_MRI` tinyint(1) unsigned DEFAULT NULL,
  `invo_other` text,
  `trtp_expe_manage` tinyint(1) unsigned DEFAULT NULL,
  `trtp_expe_manage_t` varchar(100) DEFAULT NULL,
  `trtp_superov_intr` tinyint(1) unsigned DEFAULT NULL,
  `trtp_IVF_ICSI` tinyint(1) unsigned DEFAULT NULL,
  `trtp_IVF_ICSI_test` tinyint(1) unsigned DEFAULT NULL,
  `trtp_IVF_ICSI_micro` tinyint(1) unsigned DEFAULT NULL,
  `trtp_donor_sperm_ins` tinyint(1) unsigned DEFAULT NULL,
  `trtp_vasec_rev` tinyint(1) unsigned DEFAULT NULL,
  `trtp_lifestyle_ch` tinyint(1) unsigned DEFAULT NULL,
  `trtp_weight_loss` tinyint(1) unsigned DEFAULT NULL,
  `trtp_adoption` tinyint(1) unsigned DEFAULT NULL,
  `trtp_sperm_cry` tinyint(1) unsigned DEFAULT NULL,
  `trtp_varic_rep` tinyint(1) unsigned DEFAULT NULL,
  `trtp_clomi_ther` tinyint(1) unsigned DEFAULT NULL,
  `trtp_clomi_ther_t` varchar(100) DEFAULT NULL,
  `trtp_gona_ther` tinyint(1) unsigned DEFAULT NULL,
  `trtp_gona_ther_t` varchar(100) DEFAULT NULL,
  `trtp_anticho_ther` tinyint(1) unsigned DEFAULT NULL,
  `trtp_anticho_ther_t` varchar(100) DEFAULT NULL,
  `trtp_cialis` tinyint(1) unsigned DEFAULT NULL,
  `trtp_cialis_t` varchar(100) DEFAULT NULL,
  `trtp_viagra` tinyint(1) unsigned DEFAULT NULL,
  `trtp_viagra_t` varchar(100) DEFAULT NULL,
  `trtp_refer_dr` tinyint(1) unsigned DEFAULT NULL,
  `trtp_refer_dr_t` varchar(100) DEFAULT NULL,
  `trtp_refer_reprod` tinyint(1) unsigned DEFAULT NULL,
  `trtp_proceed_invest` tinyint(1) unsigned DEFAULT NULL,
  `trtp_other` text,
  `sh_occupation_t` varchar(100) DEFAULT NULL,
  `fh_female_factor` tinyint(1) unsigned DEFAULT NULL,
  `fh_female_factor_t` varchar(100) DEFAULT NULL,
  `pci_refer_physic_fname` varchar(100) DEFAULT NULL,
  `pci_refer_physic_lname` varchar(100) DEFAULT NULL,
  `previ_y_micro_t` varchar(100) DEFAULT NULL,
  `previ_karyotype_t` varchar(100) DEFAULT NULL,
  `previ_CFTR_t` varchar(100) DEFAULT NULL,
  `pem_ht_feet_inch` varchar(10) DEFAULT NULL,
  `pem_ht_t_inch` varchar(10) DEFAULT NULL,
  `pem_wt_cmb` varchar(10) DEFAULT NULL,
  `pem_BP` tinyint(1) unsigned DEFAULT NULL,
  `pem_BP_t` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2736 DEFAULT CHARSET=latin1;