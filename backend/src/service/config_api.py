import sys
sys.path.append('..')

from typing import Any, Optional

import dataclasses
from dataclasses import dataclass
from dataclasses_json import dataclass_json
from flask import Response, jsonify, Flask

import src.const as const


@dataclass_json
@dataclass
class DetectRequest:
    name: str
    user_id: str

    def validate(self) -> [bool,str]:
        if not self.name:
            return False, 'Missing user name'
        if not self.user_id:
            return False, 'Missing user id'
        return True, ''

@dataclass_json
@dataclass
class DetectResult:
    code: int = const.CODE_PROCESSING
    message: str = const.MSG_PROCESSING
    user_id: str = None
    score_auth: Optional[float] = None


@dataclass
class ApiResponse(Response):
    default_minetype = 'application/json'
    success: bool = False
    message: Optional[str] = None
    data: Optional[Any] = None