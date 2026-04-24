USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_limitator_result_type]    Script Date: 2026-04-20 10:34:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_limitator_result_type](
	[uid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[text] [nvarchar](60) NULL,
	[code] [nvarchar](60) NULL,
	[use_result_list] [bit] NULL,
 CONSTRAINT [sys_limitator_result_type_PK] PRIMARY KEY CLUSTERED 
(
	[uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

