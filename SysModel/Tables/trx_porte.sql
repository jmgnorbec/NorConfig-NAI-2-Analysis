USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_porte]    Script Date: 2026-04-20 11:37:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_porte](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[trx_project_UID] [int] NULL,
	[trx_chambre_UID] [int] NULL,
	[trx_groupe_UID] [int] NULL,
	[IsAModel] [bit] NULL,
	[Nom] [nvarchar](500) NULL,
	[Desc] [nvarchar](max) NULL,
	[application] [int] NULL,
	[porte_type] [int] NULL,
	[seuil_type] [int] NULL,
	[rampe_type] [int] NULL,
	[rampe_profondeur] [float] NULL,
	[id_porte] [nvarchar](128) NULL,
	[porte_epaisseur] [int] NULL,
	[ouverture_largeur] [decimal](18, 4) NULL,
	[ouverture_hauteur] [decimal](18, 4) NULL,
	[cadre_epaisseur] [int] NULL,
	[cadre_largeur] [decimal](18, 4) NULL,
	[cadre_hauteur] [decimal](18, 4) NULL,
	[porte_fini_int] [int] NULL,
	[porte_fini_ext] [int] NULL,
	[cadre_fini_int] [int] NULL,
	[cadre_fini_ext] [int] NULL,
	[jonctions_type] [int] NULL,
	[jonctions_coins] [int] NULL,
	[jonctions_scellant] [int] NULL,
	[pentures_type] [int] NULL,
	[pentures_qte] [decimal](18, 0) NULL,
	[penture_poignee] [int] NULL,
	[penture_butee] [int] NULL,
	[penture_poussoir] [int] NULL,
	[penture_fermoir] [int] NULL,
	[penture_coupe_froid] [int] NULL,
	[penture_balai] [int] NULL,
	[penture_bas_de_porte_chauffant] [int] NULL,
	[penture_pedale] [int] NULL,
	[penture_verrou] [int] NULL,
	[cl_fermeture] [int] NULL,
	[cl_fermoir] [int] NULL,
	[cl_porte_chauffante] [int] NULL,
	[cl_angle_de_protection] [int] NULL,
	[cl_levier_int] [int] NULL,
	[cl_levier_ext] [int] NULL,
	[cl_serrure] [int] NULL,
	[plaque_prot_int_fini] [int] NULL,
	[plaque_prot_int_hauteur] [decimal](18, 4) NULL,
	[plaque_prot_ext_fini] [int] NULL,
	[plaque_prot_ext_hauteur] [decimal](18, 4) NULL,
	[fen_congelateur] [int] NULL,
	[fen_refrigerateur] [int] NULL,
	[fen_cadre] [int] NULL,
	[eclairage_1] [int] NULL,
	[valve_type] [int] NULL,
	[valve_qte] [decimal](18, 4) NULL,
	[seq_id] [int] NULL,
	[trx_cloison_UID] [int] NULL,
	[rail_viande] [int] NULL,
	[rail_viande_hauteur] [decimal](28, 4) NULL,
	[epi_QuoteLine] [int] NULL,
	[epi_OrderLine] [int] NULL,
	[epi_PartNum] [nvarchar](50) NULL,
	[controle1] [int] NULL,
	[controle2] [int] NULL,
	[controle3] [int] NULL,
	[controle4] [int] NULL,
	[controle5] [int] NULL,
	[controle6] [int] NULL,
	[controle1_qte] [decimal](18, 4) NULL,
	[controle2_qte] [decimal](18, 4) NULL,
	[controle3_qte] [decimal](18, 4) NULL,
	[controle4_qte] [decimal](18, 4) NULL,
	[controle5_qte] [decimal](18, 4) NULL,
	[controle6_qte] [decimal](18, 4) NULL,
	[comment] [nvarchar](max) NULL,
	[rampe_fini] [int] NULL,
	[pre_select_quincaille] [int] NULL,
	[note_interne] [nvarchar](max) NULL,
	[cadre_epaisseur_custo] [decimal](28, 10) NULL,
	[prix_memoire] [decimal](18, 4) NULL,
	[prix_memoire_ajust] [decimal](18, 4) NULL,
	[prix_ajustement] [decimal](18, 4) NULL,
	[prix_note] [nvarchar](500) NULL,
	[prix] [decimal](18, 4) NULL,
	[porte_vendue_seule] [int] NOT NULL,
	[porte_sans_cadre] [int] NOT NULL,
	[cloison_seq_id] [int] NOT NULL,
	[sens_ouverture] [int] NOT NULL,
	[position] [decimal](18, 4) NOT NULL,
	[plancher] [int] NOT NULL,
	[plafond] [int] NOT NULL,
	[bulle_sur_plan] [nvarchar](10) NOT NULL,
	[prix_avant_options] [decimal](18, 4) NOT NULL,
	[quincaillerie] [int] NULL,
	[options] [int] NULL,
	[cl_antivol] [int] NULL,
	[arret_evap] [int] NOT NULL,
	[porte_qte] [int] NOT NULL,
 CONSTRAINT [trx_porte_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_panneau_inclus]  DEFAULT ((0)) FOR [porte_vendue_seule]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_porte_sans_cadre]  DEFAULT ((0)) FOR [porte_sans_cadre]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_cloison_seq_id]  DEFAULT ((0)) FOR [cloison_seq_id]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_sens_ouverture]  DEFAULT ((0)) FOR [sens_ouverture]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_position]  DEFAULT ((0)) FOR [position]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_plancher]  DEFAULT ((0)) FOR [plancher]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_plafond]  DEFAULT ((0)) FOR [plafond]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_bulle_sur_plan]  DEFAULT ('') FOR [bulle_sur_plan]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_prix_avant_option]  DEFAULT ((0)) FOR [prix_avant_options]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_arret_evap]  DEFAULT ((0)) FOR [arret_evap]
GO

ALTER TABLE [dbo].[trx_porte] ADD  CONSTRAINT [DF_trx_porte_porte_qte]  DEFAULT ((1)) FOR [porte_qte]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Prix généré à la dernière sauvegarde' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'trx_porte', @level2type=N'COLUMN',@level2name=N'prix_memoire'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Montant de l''ajustement à ajouter au prix standard calculé (peut être négatif)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'trx_porte', @level2type=N'COLUMN',@level2name=N'prix_ajustement'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Note explicative sur la/les raison(s) de l''ajustement de prix' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'trx_porte', @level2type=N'COLUMN',@level2name=N'prix_note'
GO

