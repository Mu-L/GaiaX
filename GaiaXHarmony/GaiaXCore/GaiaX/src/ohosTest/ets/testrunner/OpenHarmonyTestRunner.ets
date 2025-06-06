import { abilityDelegatorRegistry, TestRunner } from '@kit.TestKit';
import { UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { resourceManager } from '@kit.LocalizationKit';
import { util } from '@kit.ArkTS';

let abilityDelegator: abilityDelegatorRegistry.AbilityDelegator;
let abilityDelegatorArguments: abilityDelegatorRegistry.AbilityDelegatorArgs;
let jsonPath: string = 'mock/mock-config.json';
let tag: string = 'GXTest';

async function onAbilityCreateCallback(data: UIAbility) {
  hilog.info(0x0000, 'testTag', 'onAbilityCreateCallback, data: %{public}s', JSON.stringify(data));
}

async function addAbilityMonitorCallback(err: BusinessError) {
  hilog.info(0x0000, 'testTag', 'addAbilityMonitorCallback : %{public}s', JSON.stringify(err) ?? '');
}

export default class OpenHarmonyTestRunner implements TestRunner {
  constructor() {
  }

  onPrepare() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'OpenHarmonyTestRunner OnPrepare');
  }

  async onRun() {
    let tag = 'testTag';
    hilog.info(0x0000, tag, '%{public}s', 'OpenHarmonyTestRunner onRun run');
    abilityDelegatorArguments = abilityDelegatorRegistry.getArguments()
    abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator()
    hilog.info(0x0000, tag, 'OpenHarmonyTestRunner : %{public}s', JSON.stringify(abilityDelegatorArguments) ?? '');
    let moduleName = abilityDelegatorArguments.parameters['-m'];
    let context = abilityDelegator.getAppContext().getApplicationContext().createModuleContext(moduleName);
    let mResourceManager = context.resourceManager;
    await checkMock(abilityDelegator, mResourceManager);
    const bundleName = abilityDelegatorArguments.bundleName;
    const testAbilityName: string = 'TestAbility';
    let lMonitor: abilityDelegatorRegistry.AbilityMonitor = {
      abilityName: testAbilityName,
      onAbilityCreate: onAbilityCreateCallback,
      moduleName: moduleName
    };
    abilityDelegator.addAbilityMonitor(lMonitor, addAbilityMonitorCallback)
    const want: Want = {
      bundleName: bundleName,
      abilityName: testAbilityName,
      moduleName: moduleName
    };
    abilityDelegator.startAbility(want, (err: BusinessError, data: void) => {
      hilog.info(0x0000, tag, 'startAbility : err : %{public}s', JSON.stringify(err) ?? '');
      hilog.info(0x0000, tag, 'startAbility : data : %{public}s', JSON.stringify(data) ?? '');
    })
    hilog.info(0x0000, tag, '%{public}s', 'OpenHarmonyTestRunner onRun end');
  }
}

async function checkMock(abilityDelegator: abilityDelegatorRegistry.AbilityDelegator, resourceManager: resourceManager.ResourceManager) {
  let rawFile: Uint8Array;
  try {
    rawFile = resourceManager.getRawFileContentSync(jsonPath);
    hilog.info(0x0000, tag, 'MockList file exists');
    let mockStr: string = util.TextDecoder.create('utf-8', { ignoreBOM: true }).decodeWithStream(rawFile);
    let mockMap: Record<string, string> = getMockList(mockStr);
    try {
      abilityDelegator.setMockList(mockMap)
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      hilog.error(0x0000, tag, `abilityDelegator.setMockList failed, error code: ${code}, message: ${message}.`);
    }
  } catch (error) {
    let code = (error as BusinessError).code;
    let message = (error as BusinessError).message;
    hilog.error(0x0000, tag, `ResourceManager:callback getRawFileContent failed, error code: ${code}, message: ${message}.`);
  }
}

function getMockList(jsonStr: string) {
  let jsonObj: Record<string, Object> = JSON.parse(jsonStr);
  let map: Map<string, object> = new Map<string, object>(Object.entries(jsonObj));
  let mockList: Record<string, string> = {};
  map.forEach((value: object, key: string) => {
    let realValue: string = value['source'].toString();
    mockList[key] = realValue;
  });
  hilog.info(0x0000, tag, '%{public}s', 'mock-json value:' + JSON.stringify(mockList) ?? '');
  return mockList;
}