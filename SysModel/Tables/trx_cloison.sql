USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_cloison]    Script Date: 2026-04-20 11:32:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_cloison](
	[uid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Nom] [nvarchar](50) NULL,
	[trx_groupe_UID] [int] NOT NULL,
	[trx_chambre_UID] [int] NOT NULL,
	[trx_chambre_UID_adjacent] [int] NOT NULL,
	[ParentType] [nvarchar](128) NULL,
	[ParentUID] [int] NULL,
	[seq_id] [int] NULL,
	[chambre_exterieure] [int] NULL,
	[largeur] [decimal](38, 10) NULL,
	[hauteur] [decimal](38, 10) NULL,
	[fini_int] [int] NULL,
	[fini_ext] [int] NULL,
	[parechoc_int] [int] NULL,
	[parechoc_ext] [int] NULL,
	[lambrissage] [int] NULL,
	[plaque_prot_int] [int] NULL,
	[plaque_prot_ext] [int] NULL,
	[comment] [nvarchar](max) NULL,
	[active] [int] NULL,
	[type_cloison] [int] NULL,
	[epaisseur] [int] NULL,
	[sys_forme_cloison_UID] [int] NULL,
	[renfort_int] [int] NULL,
	[renfort_ext] [int] NULL,
	[parechoc_int_mat] [int] NULL,
	[parechoc_int_ajust] [decimal](28, 4) NULL,
	[parechoc_int_hauteur] [decimal](28, 4) NULL,
	[parechoc_ext_mat] [int] NULL,
	[parechoc_ext_ajust] [decimal](28, 4) NULL,
	[parechoc_ext_hauteur] [decimal](28, 4) NULL,
	[renfort_int_mat] [int] NULL,
	[renfort_int_ajust] [decimal](28, 4) NULL,
	[renfort_ext_mat] [int] NULL,
	[renfort_ext_ajust] [decimal](28, 4) NULL,
	[plaque_prot_int_mat] [int] NULL,
	[plaque_prot_int_ajust] [decimal](28, 4) NULL,
	[plaque_prot_ext_mat] [int] NULL,
	[plaque_prot_ext_ajust] [decimal](28, 4) NULL,
	[plaque_prot_int_hauteur] [decimal](28, 4) NULL,
	[plaque_prot_ext_hauteur] [decimal](28, 4) NULL,
	[renfort_parechoc_int_mat] [int] NULL,
	[renfort_parechoc_ext_mat] [int] NULL,
	[parechoc_int_hauteur2] [decimal](28, 4) NULL,
	[parechoc_ext_hauteur2] [decimal](28, 4) NULL,
	[parechoc_int_mat2] [int] NULL,
	[parechoc_int_ajust2] [decimal](28, 4) NULL,
	[parechoc_ext_mat2] [int] NULL,
	[parechoc_ext_ajust2] [decimal](28, 4) NULL,
	[lambrissage_type] [int] NULL,
	[lambrissage_hauteur] [decimal](28, 4) NULL,
	[renfort_int_hauteur] [decimal](28, 4) NULL,
	[renfort_ext_hauteur] [decimal](28, 4) NULL,
	[custom] [int] NOT NULL,
	[nb_panneaux] [int] NULL,
	[profil_int] [int] NOT NULL,
	[profil_ext] [int] NOT NULL,
	[fini_int_cust] [int] NOT NULL,
	[fini_ext_cust] [int] NOT NULL,
	[tag] [nvarchar](50) NULL,
	[tag_ovrd] [nvarchar](50) NULL,
	[no_chambre] [int] NOT NULL,
	[no_cloison] [int] NOT NULL,
	[end1] [nvarchar](50) NOT NULL,
	[end2] [nvarchar](50) NOT NULL,
 CONSTRAINT [trx_cloison_PK] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_trx_chambre_UID_alt]  DEFAULT ((0)) FOR [trx_chambre_UID_adjacent]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_chambre_exterieure]  DEFAULT ((0)) FOR [chambre_exterieure]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_active]  DEFAULT ((1)) FOR [active]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_type_cloison]  DEFAULT ((0)) FOR [type_cloison]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_renfort_int]  DEFAULT ((0)) FOR [renfort_int]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_renfort_ext]  DEFAULT ((0)) FOR [renfort_ext]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_custom]  DEFAULT ((0)) FOR [custom]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_profil_int]  DEFAULT ((0)) FOR [profil_int]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_profil_ext]  DEFAULT ((0)) FOR [profil_ext]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_fini_int_cust]  DEFAULT ((0)) FOR [fini_int_cust]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_fini_ext_cust]  DEFAULT ((0)) FOR [fini_ext_cust]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_no_chambre]  DEFAULT ((0)) FOR [no_chambre]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_no_cloison]  DEFAULT ((0)) FOR [no_cloison]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_end1]  DEFAULT ('') FOR [end1]
GO

ALTER TABLE [dbo].[trx_cloison] ADD  CONSTRAINT [DF_trx_cloison_end2]  DEFAULT ('') FOR [end2]
GO

ALTER TABLE [dbo].[trx_cloison]  WITH CHECK ADD  CONSTRAINT [trx_cloison_trx_chambre_FK] FOREIGN KEY([trx_chambre_UID])
REFERENCES [dbo].[trx_chambre] ([UID])
GO

ALTER TABLE [dbo].[trx_cloison] CHECK CONSTRAINT [trx_cloison_trx_chambre_FK]
GO

ALTER TABLE [dbo].[trx_cloison]  WITH CHECK ADD  CONSTRAINT [trx_cloison_trx_groupe_FK] FOREIGN KEY([trx_groupe_UID])
REFERENCES [dbo].[trx_groupe] ([UID])
GO

ALTER TABLE [dbo].[trx_cloison] CHECK CONSTRAINT [trx_cloison_trx_groupe_FK]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1.Mur 2.Plancher 3.Plafond 4.Ligne commentaire' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'trx_cloison', @level2type=N'COLUMN',@level2name=N'type_cloison'
GO

