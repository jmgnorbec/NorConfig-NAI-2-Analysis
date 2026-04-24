USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_epicor_assoc]    Script Date: 2026-04-20 11:34:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_epicor_assoc](
	[no_soum] [int] NOT NULL,
	[no_comm] [int] NULL,
	[trx_project_UID] [int] NULL,
 CONSTRAINT [PK_trx_epi_assoc] PRIMARY KEY CLUSTERED 
(
	[no_soum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

