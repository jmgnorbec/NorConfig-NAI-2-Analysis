USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_chambre_vitre]    Script Date: 2026-04-20 11:32:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_chambre_vitre](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[no] [int] NULL,
	[qte] [int] NULL,
	[largeur] [decimal](28, 4) NULL,
	[hauteur] [decimal](28, 4) NULL,
	[trx_chambre_UID] [int] NOT NULL,
	[trx_cloison_UID] [int] NULL,
 CONSTRAINT [trx_chambre_vitre_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_chambre_vitre]  WITH CHECK ADD  CONSTRAINT [trx_chambre_vitre_trx_chambre_FK] FOREIGN KEY([trx_chambre_UID])
REFERENCES [dbo].[trx_chambre] ([UID])
GO

ALTER TABLE [dbo].[trx_chambre_vitre] CHECK CONSTRAINT [trx_chambre_vitre_trx_chambre_FK]
GO

