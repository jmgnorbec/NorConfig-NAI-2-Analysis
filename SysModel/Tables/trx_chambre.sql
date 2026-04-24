USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_chambre]    Script Date: 2026-04-20 11:31:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_chambre](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[IsAModel] [bit] NULL,
	[Nom] [nvarchar](50) NULL,
	[Desc] [nvarchar](max) NULL,
	[trx_groupe_UID] [int] NOT NULL,
	[seq_id] [int] NULL,
	[nom_local] [nvarchar](128) NULL,
	[numero_local] [nvarchar](128) NULL,
	[chambre_exterieure] [int] NULL,
	[forme_chambre] [int] NOT NULL,
	[chambre_type] [int] NULL,
	[plancher] [int] NULL,
	[nombre_de_murs] [int] NULL,
	[plafond] [int] NULL,
	[sens_plafond] [int] NULL,
	[coupe_plafond] [int] NULL,
	[sens_plancher] [int] NULL,
	[sens_cales] [int] NULL,
	[larg_max_pan] [decimal](28, 4) NULL,
	[long_max_pan] [decimal](28, 4) NULL,
	[forme_coin_en_l] [int] NULL,
	[forme_contour_colonne] [int] NULL,
	[forme_colonne_pan] [int] NULL,
	[forme_angle_45] [int] NULL,
	[forme_autre_angle] [int] NULL,
	[lambrissage_type] [int] NULL,
	[lambrissage_hauteur] [decimal](28, 4) NULL,
	[parechoc_int] [int] NULL,
	[parechoc_int_hauteur] [decimal](28, 4) NULL,
	[parechoc_ext] [int] NULL,
	[parechoc_ext_hauteur] [decimal](28, 4) NULL,
	[renfort_mur_int_mat] [int] NULL,
	[renfort_mur_ext_mat] [int] NULL,
	[renfort_plaf_int] [int] NULL,
	[renfort_plaf_ext] [int] NULL,
	[murs_fini_int] [int] NULL,
	[murs_epaisseur] [int] NULL,
	[murs_fini_ext] [int] NULL,
	[plafond_fini_int] [int] NULL,
	[plafond_fini_ext] [int] NULL,
	[plafond_epaisseur] [int] NULL,
	[plancher_revetement_1] [int] NULL,
	[plancher_revetement_2] [int] NULL,
	[plancher_fini_int] [int] NULL,
	[plancher_fini_ext] [int] NULL,
	[plancher_epaisseur] [int] NULL,
	[renfort_plancher_sup] [int] NULL,
	[renfort_plancher_inf] [int] NULL,
	[cales_mats] [int] NULL,
	[cales_hauteur] [decimal](28, 4) NULL,
	[jonctions_type] [int] NULL,
	[jonctions_coins] [int] NULL,
	[jonctions_scellant] [int] NULL,
	[jonctions_au_sol] [int] NULL,
	[chambre_hauteur] [decimal](28, 10) NULL,
	[profondeur_depression] [decimal](28, 10) NULL,
	[hauteur_nivellement] [decimal](28, 10) NULL,
	[murets] [decimal](28, 10) NULL,
	[riser_wall] [decimal](28, 10) NULL,
	[controle1] [int] NULL,
	[controle2] [int] NULL,
	[controle3] [int] NULL,
	[controle4] [int] NULL,
	[controle5] [int] NULL,
	[eclairage1] [int] NULL,
	[eclairage1_qte] [int] NULL,
	[eclairage2] [int] NULL,
	[eclairage2_qte] [int] NULL,
	[eclairage3] [int] NULL,
	[eclairage3_qte] [int] NULL,
	[epi_QuoteLine] [int] NULL,
	[epi_OrderLine] [int] NULL,
	[epi_PartNum] [nvarchar](50) NULL,
	[chambre_largeur] [decimal](28, 10) NULL,
	[chambre_longueur] [decimal](28, 10) NULL,
	[controle1_qte] [decimal](18, 4) NULL,
	[controle2_qte] [decimal](18, 4) NULL,
	[controle3_qte] [decimal](18, 4) NULL,
	[controle4_qte] [decimal](18, 4) NULL,
	[controle5_qte] [decimal](18, 4) NULL,
	[controle6_qte] [decimal](18, 4) NULL,
	[controle6] [int] NULL,
	[comment] [nvarchar](max) NULL,
	[valve_type] [int] NULL,
	[valve_qte] [int] NULL,
	[suspension_1] [int] NULL,
	[suspension_1_qte] [decimal](18, 4) NULL,
	[suspension_2] [int] NULL,
	[suspension_2_qte] [decimal](18, 4) NULL,
	[susp_ancrage_beton] [int] NULL,
	[susp_nb_tige_point] [int] NULL,
	[susp_porte_libre] [decimal](18, 0) NULL,
	[plaque_prot_int] [int] NULL,
	[plaque_prot_ext] [int] NULL,
	[plaque_prot_int_hauteur] [decimal](18, 4) NULL,
	[plaque_prot_ext_hauteur] [decimal](18, 4) NULL,
	[sys_forme_UID] [int] NULL,
	[note_interne] [nvarchar](max) NULL,
	[prix_memoire] [decimal](18, 4) NULL,
	[prix_memoire_ajust] [decimal](18, 4) NULL,
	[prix_ajustement] [decimal](18, 4) NULL,
	[prix_note] [nvarchar](500) NULL,
	[prix] [decimal](18, 4) NULL,
	[parechoc_int_qte] [int] NULL,
	[parechoc_ext_qte] [int] NULL,
	[prix_avant_options] [decimal](18, 4) NULL,
	[chambre_hauteur_murs] [decimal](18, 4) NULL,
	[refri_unite_partnum] [nvarchar](50) NULL,
	[refri_evap_partnum] [nvarchar](50) NULL,
	[refri_intelliref_partnum] [nvarchar](50) NULL,
	[refri_lda_partnum] [nvarchar](50) NULL,
	[refri_evap_count] [int] NULL,
	[refri_garantie_partnum] [nvarchar](50) NULL,
	[refri_support_partnum] [nvarchar](50) NULL,
	[renfort_parechoc_int] [int] NULL,
	[renfort_parechoc_ext] [int] NULL,
	[parechoc_int_hauteur2] [decimal](28, 4) NULL,
	[parechoc_ext_hauteur2] [decimal](28, 4) NULL,
	[pi2] [decimal](28, 4) NULL,
	[type_panneau] [int] NULL,
	[murs_profil_int] [int] NOT NULL,
	[murs_profil_ext] [int] NOT NULL,
	[murs_texture_int] [int] NOT NULL,
	[murs_texture_ext] [int] NOT NULL,
	[murs_cannelure] [int] NOT NULL,
	[lambrissage_comment] [nvarchar](max) NOT NULL,
	[parechoc_int_comment] [nvarchar](max) NOT NULL,
	[parechoc_ext_comment] [nvarchar](max) NOT NULL,
	[plaque_prot_int_comment] [nvarchar](max) NOT NULL,
	[plaque_prot_ext_comment] [nvarchar](max) NOT NULL,
	[architectural] [bit] NOT NULL,
	[butyl_inclus] [int] NOT NULL,
	[murs_note_int] [nvarchar](255) NOT NULL,
	[murs_note_ext] [nvarchar](255) NOT NULL,
	[refri_comment] [nvarchar](max) NULL,
 CONSTRAINT [trx_chambre_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_forme_chambre]  DEFAULT ((1000)) FOR [forme_chambre]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_profondeur_depression]  DEFAULT ((0)) FOR [profondeur_depression]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_prix_avant_options]  DEFAULT ((0)) FOR [prix_avant_options]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_refri_evap_count]  DEFAULT ((0)) FOR [refri_evap_count]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_murs_profil_int]  DEFAULT ((0)) FOR [murs_profil_int]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_murs_profil_ext]  DEFAULT ((0)) FOR [murs_profil_ext]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_murs_texture_int]  DEFAULT ((0)) FOR [murs_texture_int]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_murs_texture_ext]  DEFAULT ((0)) FOR [murs_texture_ext]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_murs_cannelure]  DEFAULT ((0)) FOR [murs_cannelure]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_lambrissage_comment]  DEFAULT ('') FOR [lambrissage_comment]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_parechoc_int_comment]  DEFAULT ('') FOR [parechoc_int_comment]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_parechoc_ext_comment]  DEFAULT ('') FOR [parechoc_ext_comment]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_plaque_prot_int_comment]  DEFAULT ('') FOR [plaque_prot_int_comment]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_plaque_prot_ext_comment]  DEFAULT ('') FOR [plaque_prot_ext_comment]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_architectural]  DEFAULT ((0)) FOR [architectural]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_butyle_inclus]  DEFAULT ((0)) FOR [butyl_inclus]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_murs_note_int]  DEFAULT ('') FOR [murs_note_int]
GO

ALTER TABLE [dbo].[trx_chambre] ADD  CONSTRAINT [DF_trx_chambre_murs_note_ext]  DEFAULT ('') FOR [murs_note_ext]
GO

ALTER TABLE [dbo].[trx_chambre]  WITH CHECK ADD  CONSTRAINT [trx_chambre_trx_groupe_FK] FOREIGN KEY([trx_groupe_UID])
REFERENCES [dbo].[trx_groupe] ([UID])
GO

ALTER TABLE [dbo].[trx_chambre] CHECK CONSTRAINT [trx_chambre_trx_groupe_FK]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Prix généré à la dernière sauvegarde' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'trx_chambre', @level2type=N'COLUMN',@level2name=N'prix_memoire'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Montant de l''ajustement à ajouter au prix standard calculé (peut être négatif)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'trx_chambre', @level2type=N'COLUMN',@level2name=N'prix_ajustement'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note explicative sur la/les raison(s) de l''ajustement de prix' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'trx_chambre', @level2type=N'COLUMN',@level2name=N'prix_note'
GO

