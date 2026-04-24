USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_groupe]    Script Date: 2026-04-20 11:35:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_groupe](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[nom_groupe] [nvarchar](50) NULL,
	[IsAModel] [bit] NULL,
	[Nom] [nvarchar](50) NULL,
	[Desc] [nvarchar](max) NULL,
	[trx_project_UID] [int] NOT NULL,
	[seq_id] [int] NULL,
	[comment] [nvarchar](max) NULL,
	[sys_forme_UID] [int] NULL,
	[col_name_value] [nvarchar](50) NOT NULL,
	[dim1] [decimal](38, 10) NULL,
	[dim2] [decimal](38, 10) NULL,
	[dim3] [decimal](38, 10) NULL,
	[dim4] [decimal](38, 10) NULL,
	[dim5] [decimal](38, 10) NULL,
	[dim6] [decimal](38, 10) NULL,
	[dim7] [decimal](38, 10) NULL,
	[dim8] [decimal](38, 10) NULL,
	[dim9] [decimal](38, 10) NULL,
	[rotation] [decimal](38, 10) NULL,
	[nom_chambre1] [nvarchar](50) NULL,
	[nom_chambre2] [nvarchar](50) NULL,
	[nom_chambre3] [nvarchar](50) NULL,
	[nom_chambre4] [nvarchar](50) NULL,
	[type_chambre1] [nvarchar](50) NULL,
	[type_chambre2] [nvarchar](50) NULL,
	[type_chambre3] [nvarchar](50) NULL,
	[type_chambre4] [nvarchar](50) NULL,
	[plafond_chambre1] [nvarchar](50) NULL,
	[plafond_chambre2] [nvarchar](50) NULL,
	[plafond_chambre3] [nvarchar](50) NULL,
	[plafond_chambre4] [nvarchar](50) NULL,
	[plafond_coupe1] [int] NULL,
	[plafond_coupe2] [int] NULL,
	[plafond_coupe3] [int] NULL,
	[plafond_coupe4] [int] NULL,
	[plancher_chambre1] [nvarchar](50) NULL,
	[plancher_chambre2] [nvarchar](50) NULL,
	[plancher_chambre3] [nvarchar](50) NULL,
	[plancher_chambre4] [nvarchar](50) NULL,
	[cales_chambre1] [nvarchar](50) NULL,
	[cales_chambre2] [nvarchar](50) NULL,
	[cales_chambre3] [nvarchar](50) NULL,
	[cales_chambre4] [nvarchar](50) NULL,
	[architectural] [bit] NOT NULL,
	[type_panneau] [int] NULL,
 CONSTRAINT [trx_groupe_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_groupe] ADD  CONSTRAINT [DF_trx_groupe_value_name]  DEFAULT (N'dim') FOR [col_name_value]
GO

ALTER TABLE [dbo].[trx_groupe] ADD  CONSTRAINT [DF_trx_groupe_architectural]  DEFAULT ((0)) FOR [architectural]
GO

ALTER TABLE [dbo].[trx_groupe]  WITH CHECK ADD  CONSTRAINT [trx_groupe_trx_project_FK] FOREIGN KEY([trx_project_UID])
REFERENCES [dbo].[trx_project] ([UID])
GO

ALTER TABLE [dbo].[trx_groupe] CHECK CONSTRAINT [trx_groupe_trx_project_FK]
GO

