USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_intran_inventor]    Script Date: 2026-04-20 10:41:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_intran_inventor](
	[uid] [int] IDENTITY(1,1) NOT NULL,
	[nom_intran_inventor] [nvarchar](150) NULL,
	[uid_categorie] [int] NULL,
	[actif] [bit] NULL,
 CONSTRAINT [PK_uni_intran_inventor2] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[uni_intran_inventor] ADD  CONSTRAINT [DF_uni_intran_inventor_uid_categorie]  DEFAULT ((0)) FOR [uid_categorie]
GO

ALTER TABLE [dbo].[uni_intran_inventor] ADD  CONSTRAINT [DF_uni_intran_inventor_actif]  DEFAULT ((1)) FOR [actif]
GO

