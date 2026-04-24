USE [Configurateur]
GO

/****** Object:  Table [dbo].[ref_param]    Script Date: 2026-04-20 10:24:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ref_param](
	[UID] [int] IDENTITY(1,1) NOT NULL,
	[context] [nvarchar](50) NULL,
	[section] [nvarchar](50) NULL,
	[specific] [nvarchar](50) NULL,
	[value] [nvarchar](250) NULL,
	[note] [nvarchar](250) NULL,
 CONSTRAINT [PK_ref_param] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

