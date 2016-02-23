
local tb	= Task:GetTarget("SearchItemWithDesc");
tb.szTargetName	= "SearchItemWithDesc";
tb.REFRESH_FRAME	= 18;	-- һ����һ��

function tb:Init(szItemName, nGenre, nDetail, nParticular, szMagic, nNeedCount, bDelete, szDynamicDesc, szStaticDesc)
	self.szItemName = szItemName;
	self.nGenre = nGenre;
	self.nDetail = nDetail;
	self.nParticular = nParticular;
	self.szMagic = szMagic;
	self.nNeedCount = nNeedCount;
	self.bDelete = bDelete;
	
	self.tbItemId = {nGenre, nDetail, nParticular, 0};
	
	self.szDynamicDesc = szDynamicDesc;
	self.szStaticDesc 	= szStaticDesc;
end;

function tb:Start()
	self:Register();
end;

function tb:Save(nGroupId, nStartTaskId)
	self.tbSaveTask	= {	-- ���ﱣ���������Ժ���ʱ��������ͬ���ͻ���
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};

	return 0;
end;

function tb:Load(nGroupId, nStartTaskId)
	self.tbSaveTask	= {	-- ���ﱣ���������Ժ���ʱ��������ͬ���ͻ���
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	
	self:Register();
	
	return 0;
end;

function tb:IsDone()
	return self:GetCount() >= self.nNeedCount;
end;

function tb:GetDesc()
	if (not self.szDynamicDesc) then
		local szMsg	= string.format("�ҵ�%s��%d/%d", self.szItemName, self:GetCount(), self.nNeedCount);
		return szMsg;
	else
		local szMsg = string.format(self.szDynamicDesc, self:GetCount());
		return szMsg;
	end
end;

function tb:GetStaticDesc()
	if (not self.szStaticDesc) then
		local szMsg	= string.format("�ҵ�%s��%d", self.szItemName, self.nNeedCount);
		return szMsg;
	else
		local szMsg = string.format(self.szStaticDesc, self.nNeedCount);
		return szMsg;
	end
end;

function tb:Close(szReason)
	self:UnRegister();
	if (MODULE_GAMESERVER) then	-- ����˿����ɾ����Ʒ
		if (szReason == "finish" and self.bDelete) then
			Task:DelItem(self.me, self.tbItemId, self.nNeedCount);
		end;
	end;
end;

function tb:Register()
	if (not self.nRegisterId) then
		self.nRegisterId	= Timer:Register(self.REFRESH_FRAME, self.OnTimer, self);
	end;
end;

function tb:UnRegister()
	if (self.nRegisterId) then
		Timer:Close(self.nRegisterId);
		self.nRegisterId	= nil;
	end;
end;

-- ����������Ʒ����
function tb:GetCount()
	return Task:GetItemCount(self.me, self.tbItemId);
end;

function tb:OnTimer(nTickCount)
	local nCount	= self:GetCount();
	if (not self.nCount or self.nCount ~= nCount) then
		self.nCount	= nCount;
		
		local tbSaveTask = self.tbSaveTask;
		if (MODULE_GAMESERVER) then	-- ����ͬ�����ͻ��ˣ�Ҫ��ͻ���ˢ��
			KTask.SendRefresh(self.me, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
		end;
		
		if (self:IsDone()) then
			self.tbTask:OnFinishOneTag();
			Task:DelItem(self.me, self.tbItemId, self.nNeedCount);
		end
	end;
	
	return self.REFRESH_FRAME;
end;