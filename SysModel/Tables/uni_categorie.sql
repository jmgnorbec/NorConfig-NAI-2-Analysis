USE [Configurateur]
GO

/****** Object:  Table [dbo].[uni_categorie]    Script Date: 2026-04-20 10:39:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[uni_categorie](
	[Uid] [int] IDENTITY(1,1) NOT NULL,
	[Nom] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_uni_categorie] PRIMARY KEY CLUSTERED 
(
	[Uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

