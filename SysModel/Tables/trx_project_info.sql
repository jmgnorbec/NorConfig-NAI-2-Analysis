USE [Configurateur]
GO

/****** Object:  Table [dbo].[trx_project_info]    Script Date: 2026-04-20 11:39:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[trx_project_info](
	[trx_project_uid] [int] NOT NULL,
	[userids] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_trx_project_user_1] PRIMARY KEY CLUSTERED 
(
	[trx_project_uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[trx_project_info]  WITH CHECK ADD  CONSTRAINT [FK_project] FOREIGN KEY([trx_project_uid])
REFERENCES [dbo].[trx_project] ([UID])
GO

ALTER TABLE [dbo].[trx_project_info] CHECK CONSTRAINT [FK_project]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comma separated list of userid' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'trx_project_info', @level2type=N'COLUMN',@level2name=N'userids'
GO

