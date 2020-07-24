import 'dart:ffi';

import 'package:BWO/game_controller.dart';

class Status {
  int _hp;
  int _maxHP;

  double _energy;
  double _maxEnergy;

  double _calories = 0;
  double _maxCalories = 100;

  int _force = 2;
  int _defense = 0;
  int _treeCut = 1;

  int _level = 1;
  int _exp = 0;
  int _maxExp = 1;

  //regenaration settings
  bool autoRegenHP = true;
  double _hpRegenFrequency = 10; //in seconds
  double _hpRegenTime = 0;
  double _energyRegenSpeed = .6;
  double _caloriesDecressSpeed = .15; //takes about 10 minutes

  Status({int maxHP = 10, double maxEnergy = 5}) {
    this._maxHP = maxHP;
    this._maxEnergy = maxEnergy;

    refillStatus();
  }

  void update(double walkSpeed) {
    _statusRegeneration(walkSpeed);
    _levelUpRamp();
  }

  void _statusRegeneration(double walkSpeed) {
    if (isAlive() == false) return;

    if (_calories > 0) {
      _calories -= GameController.deltaTime * _caloriesDecressSpeed;
    } else {
      _calories = 0;
    }

    if (walkSpeed >= 2) {
      if (_energy > 0) {
        var energyDecrease = GameController.deltaTime * _energyRegenSpeed * .7;
        energyDecrease *= walkSpeed / 3;
        _energy -= energyDecrease;
      }
    }

    if (_energy < _maxEnergy) {
      if (_calories > 0) {
        _energy += GameController.deltaTime *
            _energyRegenSpeed *
            2 *
            (_calories / 100);
      } else {
        if (_energy < _maxEnergy / 2) {
          _energy += GameController.deltaTime * 0.001;
        }
      }
    } else {
      _energy = _maxEnergy;
    }

    if (autoRegenHP == false) return;
    if (_hp < _maxHP && GameController.time > _hpRegenTime) {
      if (walkSpeed == 0) {
        _hpRegenTime = GameController.time + _hpRegenFrequency * .5;
      } else {
        _hpRegenTime = GameController.time + _hpRegenFrequency;
      }
      _hp += 1;
    }
  }

  int getLevel() {
    return _level;
  }

  int getHP() {
    return _hp;
  }

  int getMaxHP() {
    return _maxHP;
  }

  double getEnergy() {
    return _energy;
  }

  double getMaxEnergy() {
    return _maxEnergy;
  }

  int getExp() {
    return _exp;
  }

  int getMaxExp() {
    return _maxExp;
  }

  double getCalories() {
    return _calories;
  }

  double getMaxCalories() {
    return _maxCalories;
  }

  void takeDamage(int damage) {
    _hp -= damage;
    if (_hp < 0) {
      _hp = 0;
    }

    //resets the time to not auto regenerate status
    _hpRegenTime = GameController.time + _hpRegenFrequency * 2;
  }

  bool useEnergy(int energy) {
    if (_energy >= energy) {
      _energy -= energy;

      //resets the time to not auto regenerate status
      _hpRegenTime = GameController.time + _hpRegenFrequency * 2;
      return true;
    } else {
      return false;
    }
  }

  bool consumeHungriness(double calories) {
    if (_calories >= calories) {
      _calories -= calories;
      return true;
    } else {
      return false;
    }
  }

  void addLife(int life) {
    _hp += life;
    if (_hp > _maxHP) {
      _hp = _maxHP;
    }
  }

  void addEnergy(int energy) {
    _energy += energy;
    if (_energy > _maxEnergy) {
      _energy = _maxEnergy;
    }
  }

  void addHungriness(double hungriness) {
    _calories += hungriness;
    if (_calories > _maxCalories) {
      _calories = _maxCalories;
    }
  }

  bool isAlive() {
    return _hp > 0;
  }

  void refillStatus() {
    _hp = _maxHP;
    _energy = _maxEnergy;
    _calories = _maxCalories;
  }

  void setLife(int n) {
    _maxHP = n;
    _hp = _maxHP;
  }

  void addExp(int amount) {
    _exp += amount;
    _levelUpRamp();
  }

  int getBaseAttackDamage() {
    return _force;
  }

  int getBaseCutTreeDamage() {
    return _treeCut + (_force * 0.2).floor();
  }

  void _levelUpRamp() {
    int startBaseExp = 10;
    double rampMultiplier = .35;
    _maxExp =
        (_level * startBaseExp + ((_level * _level * _level) * rampMultiplier))
            .toInt();

    if (_exp > _maxExp) {
      _level++;
      _exp -= _maxExp;
      print("level up");
      _updateStatus();
      refillStatus();
    }

    _updateStatus();
  }

  void _updateStatus() {
    _maxHP = (10 + ((_level * _level) * .5)).toInt();
    _maxEnergy = (5 + _level * .5);
  }
}
