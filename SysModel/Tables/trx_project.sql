USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_project]    Script Date: 2026-04-20 11:38:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_project](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Projet] [nvarchar](50) NULL,
	[BasedOn] [int] NULL,
	[IsAModel] [bit] NULL,
	[Nom] [nvarchar](50) NULL,
	[Desc] [nvarchar](max) NULL,
	[IterationNum] [int] NULL,
	[epi_QuoteNum] [int] NULL,
	[epi_OrderNum] [int] NULL,
	[comment] [nvarchar](max) NULL,
 CONSTRAINT [Project_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

