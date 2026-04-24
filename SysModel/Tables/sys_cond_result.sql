USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_cond_result]    Script Date: 2026-04-20 10:26:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_cond_result](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ResultValue] [nvarchar](60) NULL,
	[sys_limitator_UID] [int] NOT NULL,
 CONSTRAINT [sys_cond_result_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_cond_result]  WITH CHECK ADD  CONSTRAINT [sys_cond_result_sys_limitator_FK] FOREIGN KEY([sys_limitator_UID])
REFERENCES [dbo].[sys_limitator] ([UID])
GO

ALTER TABLE [dbo].[sys_cond_result] CHECK CONSTRAINT [sys_cond_result_sys_limitator_FK]
GO

