USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_def_chambres]    Script Date: 2026-04-20 11:33:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_def_chambres](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[trx_project_UID] [int] NULL,
	[trx_groupe_uid] [int] NULL,
	[Description] [nvarchar](50) NULL,
	[murs_fini_int] [int] NULL,
	[murs_epaisseur] [int] NULL,
	[murs_fini_ext] [int] NULL,
	[plafond_fini_int] [int] NULL,
	[plafond_epaisseur] [int] NULL,
	[plafond_fini_ext] [int] NULL,
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
	[larg_max_pan] [decimal](28, 4) NULL,
	[lambrissage_type] [int] NULL,
	[lambrissage_hauteur] [decimal](28, 4) NULL,
	[renfort_mur_int_mat] [int] NULL,
	[renfort_mur_ext_mat] [int] NULL,
	[renfort_plaf_int] [int] NULL,
	[renfort_plaf_ext] [int] NULL,
	[parechoc_int] [int] NULL,
	[parechoc_int_hauteur] [decimal](28, 4) NULL,
	[parechoc_ext] [int] NULL,
	[parechoc_ext_hauteur] [decimal](28, 4) NULL,
	[controle] [int] NULL,
	[long_pan] [decimal](18, 4) NULL,
	[long_max_pan] [decimal](18, 4) NULL,
	[parechoc_haut_sol_int1] [decimal](18, 4) NULL,
	[parechoc_haut_sol_int2] [decimal](18, 4) NULL,
	[parechoc_haut_sol_ext1] [decimal](18, 4) NULL,
	[parechoc_haut_sol_ext2] [decimal](18, 4) NULL,
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
	[eclairage_cas_util1] [int] NULL,
	[eclairage_cas_util2] [int] NULL,
	[eclairage_cas_util3] [int] NULL,
	[controle6] [int] NULL,
	[plaque_prot_int] [int] NULL,
	[plaque_prot_ext] [int] NULL,
	[plaque_prot_int_hauteur] [decimal](18, 4) NULL,
	[plaque_prot_ext_hauteur] [decimal](18, 4) NULL,
 CONSTRAINT [trx_chambrev1_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_def_chambres]  WITH CHECK ADD  CONSTRAINT [trx_def_chambre_trx_project_FK] FOREIGN KEY([trx_project_UID])
REFERENCES [dbo].[trx_project] ([UID])
GO

ALTER TABLE [dbo].[trx_def_chambres] CHECK CONSTRAINT [trx_def_chambre_trx_project_FK]
GO

