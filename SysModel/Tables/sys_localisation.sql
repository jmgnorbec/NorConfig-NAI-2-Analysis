USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_localisation]    Script Date: 2026-04-20 10:34:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_localisation](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[fr] [nvarchar](max) NULL,
	[en] [nvarchar](max) NULL,
	[desc_client_fr] [nvarchar](max) NULL,
	[desc_client_en] [nvarchar](max) NULL,
 CONSTRAINT [Localisation_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

